import Foundation

extension _AMF0Decoder {
    final class KeyedContainer<Key> where Key: CodingKey {
        lazy var nestedContainers: [String: AMF0DecodingContainer] = {
            return (try? resolveContainers()) ?? [:]
         }()

        func resolveContainers() throws -> [String: AMF0DecodingContainer] {
            do {
                guard let objectMarker = try AMF0Marker(rawValue: readByte()) else {
                    return [:]
                }

                switch objectMarker {
                case .object:
                    return nestedContainersForObject()
                case .ecmaArray:
                    return nestedContainersForECMAArray()
                case .string:
                    let length = try read(UInt16.self)
                    let stringData = try read(Int(length))
                    return try resolveContainers()
                case .number:
                    let number = try read(UInt64.self)
                    return try resolveContainers()
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
        var referenceTable: ReferenceTable

        func nestedCodingPath(forKey key: CodingKey) -> [CodingKey] {
            return self.codingPath + [key]
        }
        
        init(data: Data, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any], referenceTable: ReferenceTable) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.data = data
            self.index = self.data.startIndex
            self.referenceTable = referenceTable
        }
        
        func checkCanDecodeValue(forKey key: Key) throws {
            guard self.contains(key) else {
                let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "key not found: \(key)")
                throw DecodingError.keyNotFound(key, context)
            }
        }

        func nestedContainersForObject() -> [String: AMF0DecodingContainer] {
            var nestedContainers: [String: AMF0DecodingContainer] = [:]

            do {
                var keyLength: UInt16 = try read(UInt16.self)
                while(keyLength > 0) {

                    let keyAndObject = try readKeyAndObject(keyLength: keyLength)
                    nestedContainers[keyAndObject.key] = keyAndObject.object

                    keyLength = try read(UInt16.self)
                }
                let rawByte = try readByte()
                guard let objectEndMarker = AMF0Marker(rawValue: rawByte), objectEndMarker == .objectEnd else {
                    return [:]
                }
//                do {
//                    if let potentialNextObject = try AMF0Marker(rawValue: readByte()), potentialNextObject == .object {
//                        return nestedContainers.merging(nestedContainersForObject(), uniquingKeysWith: { (left, right) -> AMF0DecodingContainer in
//                            return left
//                        })
//                    } else {
//                        self.index -= 1
//                    }
//                }
            } catch {
                fatalError("\(error)") // FIXME
            }


            return nestedContainers
        }

        func nestedContainersForECMAArray() -> [String: AMF0DecodingContainer] {
            var nestedContainers: [String: AMF0DecodingContainer] = [:]

            do {

                let count: UInt32 = try read(UInt32.self)

                for _ in 0..<count {
                    let keyLength: UInt16 = try read(UInt16.self)

                    let keyAndObject = try readKeyAndObject(keyLength: keyLength)
                    nestedContainers[keyAndObject.key] = keyAndObject.object
                }
            } catch {
                fatalError("\(error)") // FIXME
            }

            return nestedContainers
        }

        func readKeyAndObject(keyLength: UInt16) throws -> (key: String, object: AMF0DecodingContainer) {
            let utfData = try read(Int(keyLength))
            guard let key = String(data: utfData, encoding: .utf8) else {
                let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot load string")
                throw DecodingError.dataCorrupted(context)
            }

            let unkeyedContainer = UnkeyedContainer(
                data: data[self.index...],
                codingPath: codingPath,
                userInfo: userInfo,
                referenceTable: referenceTable
            )

            let containers = unkeyedContainer.nestedContainers
            if containers.isEmpty {
                let singleValueContainer = SingleValueContainer(
                    data: data[self.index...],
                    codingPath: codingPath,
                    userInfo: userInfo,
                    referenceTable: referenceTable
                )
                let length = singleValueContainer.length ?? 0
                self.index += length
                return (key, singleValueContainer)
            } else {
                unkeyedContainer.codingPath += [AnyCodingKey(stringValue: key)!]
                self.index = unkeyedContainer.index
                return (key, unkeyedContainer)
            }

        }
    }
}

extension _AMF0Decoder.KeyedContainer: KeyedDecodingContainerProtocol {
    var allKeys: [Key] {
        return self.nestedContainers.keys.map{ Key(stringValue: $0)! }
    }
    
    func contains(_ key: Key) -> Bool {
        return self.nestedContainers.keys.contains(key.stringValue)
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        try checkCanDecodeValue(forKey: key)
        
        guard let singleValueContainer = self.nestedContainers[key.stringValue] as? _AMF0Decoder.SingleValueContainer else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "cannot decode nil for key: \(key)")
            throw DecodingError.typeMismatch(Any?.self, context)
        }
        
        return singleValueContainer.decodeNil()
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        try checkCanDecodeValue(forKey: key)
        
        let container = self.nestedContainers[key.stringValue]!
        let decoder = _AMF0Decoder(data: container.data, referenceTable: self.referenceTable)
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
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        try checkCanDecodeValue(forKey: key)
        
        guard let keyedContainer = self.nestedContainers[key.stringValue] as? _AMF0Decoder.KeyedContainer<NestedKey> else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "cannot decode nested container for key: \(key)")
        }
        
        return KeyedDecodingContainer(keyedContainer)
    }
    
    func superDecoder() throws -> Decoder {
        return _AMF0Decoder(data: self.data, referenceTable: self.referenceTable)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        let decoder = _AMF0Decoder(data: self.data, referenceTable: self.referenceTable)
        decoder.codingPath = [key]
        
        return decoder
    }
}

extension _AMF0Decoder.KeyedContainer: AMF0DecodingContainer {}
