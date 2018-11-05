import Foundation

extension _AMF0Encoder {
    final class UnkeyedContainer {
        private var storage: [_AMF0EncodingContainer] = []

        var count: Int {
            return storage.count
        }

        var codingPath: [CodingKey]

        var nestedCodingPath: [CodingKey] {
            return self.codingPath + [AnyCodingKey(intValue: self.count)!]
        }

        var userInfo: [CodingUserInfoKey: Any]

        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
    }
}

extension _AMF0Encoder.UnkeyedContainer: UnkeyedEncodingContainer {
    func encodeNil() throws {
        var container = self.nestedSingleValueContainer()
        try container.encodeNil()
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        var container = self.nestedSingleValueContainer()
        try container.encode(value)
    }

    private func nestedSingleValueContainer() -> SingleValueEncodingContainer {
        let container = _AMF0Encoder.SingleValueContainer(codingPath: self.nestedCodingPath, userInfo: self.userInfo)
        self.storage.append(container)

        return container
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = _AMF0Encoder.KeyedContainer<NestedKey>(codingPath: self.nestedCodingPath, userInfo: self.userInfo)
        self.storage.append(container)

        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let container = _AMF0Encoder.UnkeyedContainer(codingPath: self.nestedCodingPath, userInfo: self.userInfo)
        self.storage.append(container)

        return container
    }

    func superEncoder() -> Encoder {
        fatalError("Unimplemented") // FIXME
    }
}

extension _AMF0Encoder.UnkeyedContainer: _AMF0EncodingContainer {
    var data: Data {
        var data = Data()

        data.append(AMF0Marker.strictArray.rawValue)
        data.append(contentsOf: UInt16(storage.count).bytes())
        storage.forEach { (container) in
            data.append(container.data)
        }
        return data
    }
}
