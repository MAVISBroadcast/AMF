import Foundation

extension _AMF0Encoder {
    final class UnkeyedContainer {
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        
        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
    }
}

extension _AMF0Encoder.UnkeyedContainer: UnkeyedEncodingContainer {
    var count: Int {
        return 0
    }

    func encodeNil() throws {

    }
    
    func encode<T>(_ value: T) throws where T : Encodable {

    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        return _AMF0Encoder.KeyedContainer<NestedKey>(codingPath: [], userInfo: [:]) as! KeyedEncodingContainer<NestedKey>
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        return _AMF0Encoder.UnkeyedContainer(codingPath: [], userInfo: [:]) as! UnkeyedEncodingContainer
    }
    
    func superEncoder() -> Encoder {
        return _AMF0Encoder()
    }
}

extension _AMF0Encoder.UnkeyedContainer: AMFEncodingContainer {}
