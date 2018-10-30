import Foundation

extension _AMFDecoder {
    final class UnkeyedContainer {
        var data: Data
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
       
        init(data: Data, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
            self.data = data
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
    }
}

extension _AMFDecoder.UnkeyedContainer: UnkeyedDecodingContainer {
    var count: Int? {
        return 0
    }

    var isAtEnd: Bool {
        return false
    }

    var currentIndex: Int {
        return 0
    }

    func decodeNil() throws -> Bool {
        return false
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try type.init(from: _AMFDecoder(data: Data()))
    }
    
    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        return _AMFDecoder.UnkeyedContainer(data: data, codingPath: codingPath, userInfo: userInfo)
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        return _AMFDecoder.KeyedContainer<NestedKey>(data: data, codingPath: codingPath, userInfo: userInfo) as! KeyedDecodingContainer<NestedKey>
    }

    func superDecoder() throws -> Decoder {
        return _AMFDecoder(data: Data())
    }
}

extension _AMFDecoder.UnkeyedContainer: AMFDecodingContainer {}
