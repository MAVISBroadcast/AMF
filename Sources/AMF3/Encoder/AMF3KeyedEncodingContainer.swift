import Foundation

extension _AMF3Encoder {
    final class KeyedContainer<Key> where Key: CodingKey {
        private var storage: [AnyCodingKey: AMF3EncodingContainer] = [:]

        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]

        func nestedCodingPath(forKey key: CodingKey) -> [CodingKey] {
            return codingPath + [key]
        }

        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
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
        let container = _AMF3Encoder.SingleValueContainer(codingPath: nestedCodingPath(forKey: key), userInfo: userInfo)
        storage[AnyCodingKey(key)] = container
        return container
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let container = _AMF3Encoder.UnkeyedContainer(codingPath: nestedCodingPath(forKey: key), userInfo: userInfo)
        storage[AnyCodingKey(key)] = container

        return container
    }

    func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let container = _AMF3Encoder.KeyedContainer<NestedKey>(codingPath: nestedCodingPath(forKey: key), userInfo: userInfo)
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

        if let encodeAsECMAArray = userInfo[AMF3Encoder.EncodeAsECMAArray] as? Bool, encodeAsECMAArray {
            data.append(AMF3Marker.ecmaArray.rawValue)
            data.append(contentsOf: UInt32(storage.count).bytes())
        } else {
            data.append(AMF3Marker.object.rawValue)
        }

        for (key, container) in storage {
            let stringKey = key.stringValue
            let utfData = stringKey.data(using: .utf8)!
            data.append(contentsOf: UInt16(utfData.count).bytes())
            data.append(utfData)
            data.append(container.data)
        }

        let emptyKey = UInt16(0).bytes()
        data.append(contentsOf: emptyKey)
        data.append(AMF3Marker.objectEnd.rawValue)

        return data
    }
}
