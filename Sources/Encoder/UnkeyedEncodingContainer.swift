import Foundation

extension _AMF0Encoder {
    final class UnkeyedContainer {
        private var storage: [AMF0EncodingContainer] = []

        var count: Int {
            return storage.count
        }

        var codingPath: [CodingKey]

        var nestedCodingPath: [CodingKey] {
            return codingPath + [AnyCodingKey(intValue: self.count)!]
        }

        var userInfo: [CodingUserInfoKey: Any]

        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
    }
}

extension _AMF0Encoder.UnkeyedContainer: UnkeyedEncodingContainer {
    func encodeNil() throws {
        var container = nestedSingleValueContainer()
        try container.encodeNil()
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        var container = nestedSingleValueContainer()
        try container.encode(value)
    }

    private func nestedSingleValueContainer() -> SingleValueEncodingContainer {
        let container = _AMF0Encoder.SingleValueContainer(codingPath: nestedCodingPath, userInfo: userInfo)
        storage.append(container)

        return container
    }

    func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let container = _AMF0Encoder.KeyedContainer<NestedKey>(codingPath: nestedCodingPath, userInfo: userInfo)
        storage.append(container)

        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let container = _AMF0Encoder.UnkeyedContainer(codingPath: nestedCodingPath, userInfo: userInfo)
        storage.append(container)

        return container
    }

    func superEncoder() -> Encoder {
        fatalError("Unimplemented") // FIXME:
    }
}

extension _AMF0Encoder.UnkeyedContainer: AMF0EncodingContainer {
    var data: Data {
        var data = Data()

        data.append(AMF0Marker.strictArray.rawValue)
        data.append(contentsOf: UInt32(storage.count).bytes())
        storage.forEach { container in
            data.append(container.data)
        }
        return data
    }
}
