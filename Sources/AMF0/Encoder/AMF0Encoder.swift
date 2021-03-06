import Foundation

/**

 */
public class AMF0Encoder {
    public static let EncodeAsECMAArray: CodingUserInfoKey = CodingUserInfoKey(rawValue: "EncodeAsECMAArray")!
    public static let EncodeStringsAsBoolsIfTrueOrFalseInECMAArray: CodingUserInfoKey = CodingUserInfoKey(rawValue: "EncodeStringsAsBoolsIfTrueOrFalseInECMAArray")!
    public static let EncodeStringsAsNumbersIfDoublesInECMAArray: CodingUserInfoKey = CodingUserInfoKey(rawValue: "EncodeStringsAsNumbersIfDoublesInECMAArray")!

    public var userInfo: [CodingUserInfoKey: Any] = [:]

    public init() {}

    public func encode(_ value: Encodable) throws -> Data {
        let encoder = _AMF0Encoder()
        encoder.userInfo = userInfo

        switch value {
        case let data as Data:
            try Box<Data>(data).encode(to: encoder)
        case let date as Date:
            try Box<Date>(date).encode(to: encoder)
        case let dictionary as [String: String]:
            encoder.userInfo[AMF0Encoder.EncodeAsECMAArray] = true
            try Box<[String: String]>(dictionary).encode(to: encoder)
        case let dictionary as [String: Double]:
            encoder.userInfo[AMF0Encoder.EncodeAsECMAArray] = true
            try Box<[String: Double]>(dictionary).encode(to: encoder)
        default:
            try value.encode(to: encoder)
        }

        return encoder.data
    }
}

final class _AMF0Encoder {
    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey: Any] = [:]

    fileprivate var container: AMF0EncodingContainer?

    var data: Data {
        return container?.data ?? Data()
    }
}

extension _AMF0Encoder: Encoder {
    fileprivate func assertCanCreateContainer() {
        precondition(container == nil)
    }

    func container<Key>(keyedBy _: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        assertCanCreateContainer()

        let container = KeyedContainer<Key>(codingPath: codingPath, userInfo: userInfo)
        self.container = container

        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        assertCanCreateContainer()

        let container = UnkeyedContainer(codingPath: codingPath, userInfo: userInfo)
        self.container = container

        return container
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        assertCanCreateContainer()

        let container = SingleValueContainer(codingPath: codingPath, userInfo: userInfo)
        self.container = container

        return container
    }
}

protocol AMF0EncodingContainer: class {
    var data: Data { get }
}
