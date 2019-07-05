import Foundation

extension _AMF3Encoder {
    final class KeyedContainer<Key> where Key: CodingKey {
        private var storage: [AnyCodingKey: AMF3EncodingContainer] = [:]

        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var referenceTable: AMF3EncodingReferenceTable

        func nestedCodingPath(forKey key: CodingKey) -> [CodingKey] {
            return codingPath + [key]
        }

        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any], referenceTable: AMF3EncodingReferenceTable) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.referenceTable = referenceTable
        }

        func dataFromTraits(_ traits: AMF3TraitsInfo) throws -> Data {
            if let _ = referenceTable.encodingObjectTraitsTable.firstIndex(of: traits) {
                // TODO: encode traits index
                fatalError("Not implemented")
            }
            var infoBits = UInt32(0b11) // Not a reference, nor traits reference
            if traits.externalisable {
                fatalError("Not implemented")
            }
            if traits.dynamic {
                infoBits = infoBits | 0b1000
            }
            infoBits = infoBits | UInt32(traits.properties.count << 4)

            let singleValueContainer = SingleValueContainer(
                codingPath: codingPath,
                userInfo: userInfo,
                referenceTable: referenceTable
            )
            singleValueContainer.supressMarkerEncoding = true

            try singleValueContainer.encode(Data(infoBits.variableBytes()))

            try singleValueContainer.encode(traits.className)

            try traits.properties.forEach { property in
                try singleValueContainer.encode(property)
            }

            return singleValueContainer.data
        }
    }
}

extension _AMF3Encoder.KeyedContainer: KeyedEncodingContainerProtocol {
    func encodeNil(forKey key: Key) throws {
        var container = nestedSingleValueContainer(forKey: key)
        try container.encodeNil()
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
        var container = nestedSingleValueContainer(forKey: key)
        try container.encode(value)
    }

    private func nestedSingleValueContainer(forKey key: Key) -> SingleValueEncodingContainer {
        let container = _AMF3Encoder.SingleValueContainer(codingPath: nestedCodingPath(forKey: key), userInfo: userInfo, referenceTable: referenceTable)
        storage[AnyCodingKey(key)] = container
        return container
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let container = _AMF3Encoder.UnkeyedContainer(codingPath: nestedCodingPath(forKey: key), userInfo: userInfo, referenceTable: referenceTable)
        storage[AnyCodingKey(key)] = container

        return container
    }

    func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let container = _AMF3Encoder.KeyedContainer<NestedKey>(codingPath: nestedCodingPath(forKey: key), userInfo: userInfo, referenceTable: referenceTable)
        storage[AnyCodingKey(key)] = container

        return KeyedEncodingContainer(container)
    }

    func superEncoder() -> Encoder {
        fatalError("Unimplemented") // FIXME:
    }

    func superEncoder(forKey _: Key) -> Encoder {
        fatalError("Unimplemented") // FIXME:
    }
}

extension _AMF3Encoder.KeyedContainer: AMF3EncodingContainer {
    var data: Data {
        var data = Data()

        data.append(AMF3Marker.object.rawValue)

        let traitsInfo = AMF3TraitsInfo(
            className: "",
            dynamic: true,
            externalisable: false,
            count: 0,
            properties: []
        )
        data.append(try! dataFromTraits(traitsInfo))

        for (key, container) in storage {
            if traitsInfo.dynamic {
                let singleValueContainer = _AMF3Encoder.SingleValueContainer(
                    codingPath: codingPath,
                    userInfo: userInfo,
                    referenceTable: referenceTable
                )
                singleValueContainer.supressMarkerEncoding = true
                try! singleValueContainer.encode(key.stringValue)
                data.append(singleValueContainer.data)
            }

            data.append(container.data)
        }

        let emptyStringKey = UInt8(1)
        data.append(emptyStringKey)

        return data
    }
}
