import Foundation

extension _AMF3Encoder {
    final class UnkeyedContainer {
        private var storage: [AMF3EncodingContainer] = []

        var count: Int {
            return storage.count
        }

        var codingPath: [CodingKey]

        var nestedCodingPath: [CodingKey] {
            return codingPath + [AnyCodingKey(intValue: self.count)!]
        }

        var userInfo: [CodingUserInfoKey: Any]
        var referenceTable: AMF3EncodingReferenceTable

        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any], referenceTable: AMF3EncodingReferenceTable) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.referenceTable = referenceTable
        }
    }
}

extension _AMF3Encoder.UnkeyedContainer: UnkeyedEncodingContainer {
    func encodeNil() throws {
        var container = nestedSingleValueContainer()
        try container.encodeNil()
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        var container = nestedSingleValueContainer()
        try container.encode(value)
    }

    private func nestedSingleValueContainer() -> SingleValueEncodingContainer {
        let container = _AMF3Encoder.SingleValueContainer(codingPath: nestedCodingPath, userInfo: userInfo, referenceTable: referenceTable)
        storage.append(container)

        return container
    }

    func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let container = _AMF3Encoder.KeyedContainer<NestedKey>(codingPath: nestedCodingPath, userInfo: userInfo, referenceTable: referenceTable)
        storage.append(container)

        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let container = _AMF3Encoder.UnkeyedContainer(codingPath: nestedCodingPath, userInfo: userInfo, referenceTable: referenceTable)
        storage.append(container)

        return container
    }

    func superEncoder() -> Encoder {
        fatalError("Unimplemented") // FIXME:
    }
}

extension _AMF3Encoder.UnkeyedContainer: AMF3EncodingContainer {
    var data: Data {
        var data = Data()

        data.append(AMF3Marker.array.rawValue)

        let countAndReferenceFlag = UInt32(storage.count << 1 | 1)
        data.append(contentsOf: try! countAndReferenceFlag.variableBytes())

        let emptyString = UInt8(0x01)
        data.append(emptyString)

        storage.forEach { container in
            data.append(container.data)
        }
        return data
    }
}
