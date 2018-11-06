import Foundation

extension _AMF0Decoder {
    final class KeyedContainer<Key> where Key: CodingKey {
        lazy var nestedContainers: [String: AMF0DecodingContainer] = {
            (try? resolveContainers()) ?? [:]
        }()

        func resolveContainers() throws -> [String: AMF0DecodingContainer] {
            do {
                guard let objectMarker = try AMF0Marker(rawValue: readByte()) else {
                    return [:]
                }

                switch objectMarker {
                case .typedObject:
                    let classNameLength: UInt16 = try read(UInt16.self)
                    let classNameUTFData = try read(Int(classNameLength))

                    guard let className = String(data: classNameUTFData, encoding: .utf8) else {
                        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot load string")
                        throw DecodingError.dataCorrupted(context)
                    }
                    
                    self.className = className
                    fallthrough
                case .object:
                    return nestedContainersForObject()
                case .ecmaArray:
                    return nestedContainersForECMAArray()
                default:
                    return [:]
                }
            } catch {
                return [:]
            }
        }

        var data: Data
        var index: Data.Index
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var referenceTable: DecodingReferenceTable
        var className: String?

        func nestedCodingPath(forKey key: CodingKey) -> [CodingKey] {
            return codingPath + [key]
        }

        init(data: Data, codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any], referenceTable: DecodingReferenceTable) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.data = data
            index = self.data.startIndex
            self.referenceTable = referenceTable
        }

        func checkCanDecodeValue(forKey key: Key) throws {
            guard contains(key) else {
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "key not found: \(key)")
                throw DecodingError.keyNotFound(key, context)
            }
        }

        func nestedContainersForObject() -> [String: AMF0DecodingContainer] {
            var nestedContainers: [String: AMF0DecodingContainer] = [:]

            do {
                var keyLength: UInt16 = try read(UInt16.self)
                while keyLength > 0 {
                    let keyAndObject = try readKeyAndObject(keyLength: keyLength)
                    nestedContainers[keyAndObject.key] = keyAndObject.object

                    keyLength = try read(UInt16.self)
                }
                let rawByte = try readByte()
                guard let objectEndMarker = AMF0Marker(rawValue: rawByte), objectEndMarker == .objectEnd else {
                    return [:]
                }
            } catch {
                fatalError("\(error)") // FIXME:
            }

            return nestedContainers
        }

        func nestedContainersForECMAArray() -> [String: AMF0DecodingContainer] {
            var nestedContainers: [String: AMF0DecodingContainer] = [:]

            do {
                let count: UInt32 = try read(UInt32.self)

                for _ in 0 ..< count {
                    let keyLength: UInt16 = try read(UInt16.self)

                    let keyAndObject = try readKeyAndObject(keyLength: keyLength)
                    nestedContainers[keyAndObject.key] = keyAndObject.object
                }

                let emptyLength = try read(UInt16.self)
                let rawByte = try readByte()
                guard emptyLength == 0, let objectEndMarker = AMF0Marker(rawValue: rawByte), objectEndMarker == .objectEnd else {
                    return [:]
                }
            } catch {
                fatalError("\(error)") // FIXME:
            }

            return nestedContainers
        }

        func readKeyAndObject(keyLength: UInt16) throws -> (key: String, object: AMF0DecodingContainer) {
            let utfData = try read(Int(keyLength))
            guard let key = String(data: utfData, encoding: .utf8) else {
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot load string")
                throw DecodingError.dataCorrupted(context)
            }

            let unkeyedContainer = UnkeyedContainer(
                data: data[self.index...],
                codingPath: codingPath,
                userInfo: userInfo,
                referenceTable: referenceTable
            )

            let keyedContainer = KeyedContainer(
                data: data[self.index...],
                codingPath: codingPath,
                userInfo: userInfo,
                referenceTable: referenceTable
            )

            let containers = unkeyedContainer.nestedContainers
            let keyedContainerNestedContainers = keyedContainer.nestedContainers
            if containers.isEmpty && keyedContainerNestedContainers.isEmpty {
                let singleValueContainer = SingleValueContainer(
                    data: data[self.index...],
                    codingPath: codingPath,
                    userInfo: userInfo,
                    referenceTable: referenceTable
                )
                let length = singleValueContainer.length ?? 0
                index += length
                return (key, singleValueContainer)
            } else if !containers.isEmpty {
                unkeyedContainer.codingPath += [AnyCodingKey(stringValue: key)!]
                index = unkeyedContainer.index
                return (key, unkeyedContainer)
            } else {
                keyedContainer.codingPath += [AnyCodingKey(stringValue: key)!]
                index = keyedContainer.index
                return (key, keyedContainer)
            }
        }
    }
}

extension _AMF0Decoder.KeyedContainer: KeyedDecodingContainerProtocol {
    var allKeys: [Key] {
        return nestedContainers.keys.map { Key(stringValue: $0)! }
    }

    func contains(_ key: Key) -> Bool {
        return nestedContainers.keys.contains(key.stringValue)
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        try checkCanDecodeValue(forKey: key)

        guard let singleValueContainer = self.nestedContainers[key.stringValue] as? _AMF0Decoder.SingleValueContainer else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "cannot decode nil for key: \(key)")
            throw DecodingError.typeMismatch(Any?.self, context)
        }

        return singleValueContainer.decodeNil()
    }

    func decode<T>(_: T.Type, forKey key: Key) throws -> T where T: Decodable {
        try checkCanDecodeValue(forKey: key)

        let container = nestedContainers[key.stringValue]!
        let decoder = _AMF0Decoder(data: container.data, referenceTable: referenceTable)
        let value = try T(from: decoder)

        return value
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        try checkCanDecodeValue(forKey: key)

        guard let unkeyedContainer = self.nestedContainers[key.stringValue] as? _AMF0Decoder.UnkeyedContainer else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "cannot decode nested container for key: \(key)")
        }

        return unkeyedContainer
    }

    func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        try checkCanDecodeValue(forKey: key)

        guard let keyedContainer = self.nestedContainers[key.stringValue] as? _AMF0Decoder.KeyedContainer<NestedKey> else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "cannot decode nested container for key: \(key)")
        }

        return KeyedDecodingContainer(keyedContainer)
    }

    func superDecoder() throws -> Decoder {
        return _AMF0Decoder(data: data, referenceTable: referenceTable)
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        let decoder = _AMF0Decoder(data: data, referenceTable: referenceTable)
        decoder.codingPath = [key]

        return decoder
    }
}

extension _AMF0Decoder.KeyedContainer: AMF0DecodingContainer {}
