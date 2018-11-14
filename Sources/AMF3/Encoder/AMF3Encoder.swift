import Foundation

/**

 */
public class AMF3Encoder {
    public func encode(_ value: Encodable) throws -> Data {
        let encoder = _AMF3Encoder()

        switch value {
        case let data as Data:
            try Box<Data>(data).encode(to: encoder)
        case let date as Date:
            try Box<Date>(date).encode(to: encoder)
        default:
            try value.encode(to: encoder)
        }

        return encoder.data
    }
}

final class _AMF3Encoder {
    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey: Any] = [:]

    fileprivate var container: AMF3EncodingContainer?

    var referenceTable = AMF3EncodingReferenceTable()

    var data: Data {
        return container?.data ?? Data()
    }
}

extension _AMF3Encoder: Encoder {
    fileprivate func assertCanCreateContainer() {
        precondition(container == nil)
    }

    func container<Key>(keyedBy _: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        assertCanCreateContainer()

        let container = KeyedContainer<Key>(codingPath: codingPath, userInfo: userInfo, referenceTable: referenceTable)
        self.container = container

        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        assertCanCreateContainer()

        let container = UnkeyedContainer(codingPath: codingPath, userInfo: userInfo, referenceTable: referenceTable)
        self.container = container

        return container
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        assertCanCreateContainer()

        let container = SingleValueContainer(codingPath: codingPath, userInfo: userInfo, referenceTable: referenceTable)
        self.container = container

        return container
    }
}

protocol AMF3EncodingContainer: class {
    var data: Data { get }
}
