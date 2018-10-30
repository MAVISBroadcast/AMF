import Foundation

extension _AMF0Encoder {
    final class KeyedContainer<Key> where Key: CodingKey {
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        
        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
    }
}

extension _AMF0Encoder.KeyedContainer: KeyedEncodingContainerProtocol {
    func encodeNil(forKey key: Key) throws {

    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {

    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        return _AMF0Encoder.UnkeyedContainer(codingPath: codingPath, userInfo: userInfo)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        return _AMF0Encoder.KeyedContainer<NestedKey>(codingPath: [], userInfo: [:]) as! KeyedEncodingContainer<NestedKey>
    }
    
    func superEncoder() -> Encoder {
        return _AMF0Encoder()
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        return _AMF0Encoder()
    }
}

extension _AMF0Encoder.KeyedContainer: AMFEncodingContainer {}
