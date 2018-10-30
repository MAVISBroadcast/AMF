import Foundation

extension _AMFDecoder {
    final class KeyedContainer<Key> where Key: CodingKey {
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

extension _AMFDecoder.KeyedContainer: KeyedDecodingContainerProtocol {
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
        return try type.init(from: _AMFDecoder(data: Data()))
    }
    
 
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        return _AMFDecoder.UnkeyedContainer(data: data, codingPath: codingPath, userInfo: userInfo)
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        return _AMFDecoder.KeyedContainer<NestedKey>(data: data, codingPath: codingPath, userInfo: userInfo) as! KeyedDecodingContainer<NestedKey>
    }
    
    func superDecoder() throws -> Decoder {
        return _AMFDecoder(data: self.data)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        let decoder = _AMFDecoder(data: self.data)
        decoder.codingPath = [key]
        return decoder
    }
}

extension _AMFDecoder.KeyedContainer: AMFDecodingContainer {}
