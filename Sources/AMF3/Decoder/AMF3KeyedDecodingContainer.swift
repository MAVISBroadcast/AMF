import Foundation

extension _AMF3Decoder {
    final class KeyedContainer<Key> where Key: CodingKey {
        lazy var nestedContainers: [String: AMF3DecodingContainer] = {
            (try? resolveContainers()) ?? [:]
        }()

        func resolveContainers() throws -> [String: AMF3DecodingContainer] {
            do {
                guard let objectMarker = try AMF3Marker(rawValue: readByte()) else {
                    return [:]
                }

                switch objectMarker {
                case .object:
                    return try nestedContainersForObject()
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
        var referenceTable: AMF3DecodingReferenceTable
        var className: String?

        func nestedCodingPath(forKey key: CodingKey) -> [CodingKey] {
            return codingPath + [key]
        }

        init(data: Data, codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any], referenceTable: AMF3DecodingReferenceTable) {
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

        func nestedContainersForObject() throws -> [String: AMF3DecodingContainer] {
            var nestedContainers: [String: AMF3DecodingContainer] = [:]

            let traitsOrRefU29 = UInt32(variableBytes: data[index...])

            if traitsOrRefU29 & 1 == 0 {
                // TODO: This is a reference, return reference nested containers
            }

            index += traitsOrRefU29.variableLength ?? 1
            let traits = try decodeTraits(infoBits: traitsOrRefU29, data: data[index...])
            referenceTable.decodingObjectTraitsTable.append(traits)

            do {
                let singleValueDecodingContainer = SingleValueContainer(
                    data: data[index...],
                    codingPath: codingPath,
                    userInfo: userInfo,
                    referenceTable: referenceTable
                )
                singleValueDecodingContainer.forcedMarker = .string
                var key = try singleValueDecodingContainer.decode(String.self)

                index = singleValueDecodingContainer.index

                while key.isEmpty == false {
                    let object = try readObject(key: key)
                    nestedContainers[key] = object
                    singleValueDecodingContainer.index = index

                    key = (try? singleValueDecodingContainer.decode(String.self)) ?? ""
                }
            } catch {
                fatalError("\(error)") // FIXME:
            }

            return nestedContainers
        }

        private func decodeTraits(infoBits: UInt32, data: Data) throws -> AMF3TraitsInfo {
            if ((infoBits & 3) == 1) {
                let traitsIndex = (infoBits >> 2)
                return referenceTable.decodingObjectTraitsTable[Int(traitsIndex)]
            }
            let externalizable = (infoBits & 4) == 4;
            let dynamic = (infoBits & 8) == 8;
            let count = infoBits >> 4;

            let singleValueDecodingContainer = SingleValueContainer(
                data: data,
                codingPath: codingPath,
                userInfo: userInfo,
                referenceTable: referenceTable
            )
            singleValueDecodingContainer.forcedMarker = .string
            let className = try singleValueDecodingContainer.decode(String.self)


            let properties = try (0..<count).map { (_) -> String in
                return try singleValueDecodingContainer.decode(String.self)
            }

            let info = AMF3TraitsInfo.init(
                className: className,
                dynamic: dynamic,
                externalisable: externalizable,
                count: count,
                properties: properties
            )

            index = singleValueDecodingContainer.index

            return info
        }

        private func readObject(key: String) throws -> AMF3DecodingContainer {

                let singleValueContainer = SingleValueContainer(
                    data: data[self.index...],
                    codingPath: codingPath,
                    userInfo: userInfo,
                    referenceTable: referenceTable
                )
                let length = singleValueContainer.length ?? 0
                index += length
                return singleValueContainer
        }
    }
}

extension _AMF3Decoder.KeyedContainer: KeyedDecodingContainerProtocol {
    var allKeys: [Key] {
        return nestedContainers.keys.map { Key(stringValue: $0)! }
    }

    func contains(_ key: Key) -> Bool {
        return nestedContainers.keys.contains(key.stringValue)
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        try checkCanDecodeValue(forKey: key)

        guard let singleValueContainer = self.nestedContainers[key.stringValue] as? _AMF3Decoder.SingleValueContainer else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "cannot decode nil for key: \(key)")
            throw DecodingError.typeMismatch(Any?.self, context)
        }

        return singleValueContainer.decodeNil()
    }

    func decode<T>(_: T.Type, forKey key: Key) throws -> T where T: Decodable {
        try checkCanDecodeValue(forKey: key)

        let container = nestedContainers[key.stringValue]!
        let decoder = _AMF3Decoder(data: container.data, referenceTable: referenceTable)
        let value = try T(from: decoder)

        return value
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        try checkCanDecodeValue(forKey: key)

        guard let unkeyedContainer = self.nestedContainers[key.stringValue] as? _AMF3Decoder.UnkeyedContainer else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "cannot decode nested container for key: \(key)")
        }

        return unkeyedContainer
    }

    func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        try checkCanDecodeValue(forKey: key)

        guard let keyedContainer = self.nestedContainers[key.stringValue] as? _AMF3Decoder.KeyedContainer<NestedKey> else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "cannot decode nested container for key: \(key)")
        }

        return KeyedDecodingContainer(keyedContainer)
    }

    func superDecoder() throws -> Decoder {
        return _AMF3Decoder(data: data, referenceTable: referenceTable)
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        let decoder = _AMF3Decoder(data: data, referenceTable: referenceTable)
        decoder.codingPath = [key]

        return decoder
    }
}

extension _AMF3Decoder.KeyedContainer: AMF3DecodingContainer {}
