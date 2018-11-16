import Foundation

/**

 */
public final class AMF0Decoder {
    #if DEBUG
        var _decoder: _AMF0Decoder?
    #endif
    public var finishedIndex: Data.Index = 0

    public init() {}

    public func decode<T>(_: T.Type, from data: Data) throws -> T where T: Decodable {
        let decoder = _AMF0Decoder(data: data, referenceTable: AMF0DecodingReferenceTable())
        #if DEBUG
            _decoder = decoder
        #endif
        defer { finishedIndex = decoder.container?.index ?? 0 }
        return try T(from: decoder)
    }
}

final class _AMF0Decoder {
    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey: Any] = [:]

    var container: AMF0DecodingContainer?
    fileprivate var data: Data

    let referenceTable: AMF0DecodingReferenceTable

    init(data: Data, referenceTable: AMF0DecodingReferenceTable) {
        self.data = data
        self.referenceTable = referenceTable
    }
}

extension _AMF0Decoder: Decoder {
    fileprivate func assertCanCreateContainer() {
        precondition(container == nil)
    }

    func container<Key>(keyedBy _: Key.Type) -> KeyedDecodingContainer<Key> where Key: CodingKey {
        assertCanCreateContainer()

        let container = KeyedContainer<Key>(data: data, codingPath: codingPath, userInfo: userInfo, referenceTable: referenceTable)
        referenceTable.decodingArray.append(container)
        self.container = container

        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedDecodingContainer {
        assertCanCreateContainer()

        let container = UnkeyedContainer(data: data, codingPath: codingPath, userInfo: userInfo, referenceTable: referenceTable)
        referenceTable.decodingArray.append(container)
        self.container = container

        return container
    }

    func singleValueContainer() -> SingleValueDecodingContainer {
        assertCanCreateContainer()

        let container = SingleValueContainer(data: data, codingPath: codingPath, userInfo: userInfo, referenceTable: referenceTable)
        self.container = container

        return container
    }
}

protocol AMF0DecodingContainer: class {
    var codingPath: [CodingKey] { get set }

    var userInfo: [CodingUserInfoKey: Any] { get }

    var data: Data { get set }
    var index: Data.Index { get set }
}

extension AMF0DecodingContainer {
    func readByte() throws -> UInt8 {
        return try read(1).first!
    }

    func read(_ length: Int) throws -> Data {
        let nextIndex = index.advanced(by: length)
        guard nextIndex <= data.endIndex else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Unexpected end of data")
            throw DecodingError.dataCorrupted(context)
        }
        defer { self.index = nextIndex }

        return data[self.index ..< nextIndex]
    }

    func read<T>(_: T.Type, endianness: Endianness = .big) throws -> T where T: FixedWidthInteger {
        let stride = MemoryLayout<T>.stride
        let bytes = [UInt8](try read(stride))
        return T(bytes: bytes, endianness: endianness)
    }
}
