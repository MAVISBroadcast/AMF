import Foundation

extension _AMF0Decoder {
    final class UnkeyedContainer {
        var data: Data
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var index: Data.Index
       
        init(data: Data, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
            self.data = data
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.index = data.startIndex
        }
    }
}

extension _AMF0Decoder.UnkeyedContainer: UnkeyedDecodingContainer {
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
        return try type.init(from: _AMF0Decoder(data: Data()))
    }
    
    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        return _AMF0Decoder.UnkeyedContainer(data: data, codingPath: codingPath, userInfo: userInfo)
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        return _AMF0Decoder.KeyedContainer<NestedKey>(data: data, codingPath: codingPath, userInfo: userInfo) as! KeyedDecodingContainer<NestedKey>
    }

    func superDecoder() throws -> Decoder {
        return _AMF0Decoder(data: Data())
    }
}

extension _AMF0Decoder.UnkeyedContainer: AMFDecodingContainer {}
