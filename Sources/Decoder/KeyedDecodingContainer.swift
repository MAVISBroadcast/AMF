import Foundation

extension _AMF0Decoder {
    final class KeyedContainer<Key> where Key: CodingKey {
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

extension _AMF0Decoder.KeyedContainer: KeyedDecodingContainerProtocol {
    var allKeys: [Key] {
        return []
    }
    
    func contains(_ key: Key) -> Bool {
        return false
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        return false
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        return try type.init(from: _AMF0Decoder(data: Data()))
    }
    
 
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        return _AMF0Decoder.UnkeyedContainer(data: data, codingPath: codingPath, userInfo: userInfo)
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        return _AMF0Decoder.KeyedContainer<NestedKey>(data: data, codingPath: codingPath, userInfo: userInfo) as! KeyedDecodingContainer<NestedKey>
    }
    
    func superDecoder() throws -> Decoder {
        return _AMF0Decoder(data: self.data)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        let decoder = _AMF0Decoder(data: self.data)
        decoder.codingPath = [key]
        return decoder
    }
}

extension _AMF0Decoder.KeyedContainer: AMFDecodingContainer {}
