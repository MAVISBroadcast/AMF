import Foundation

extension _AMFEncoder {
    final class UnkeyedContainer {
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        
        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
    }
}

extension _AMFEncoder.UnkeyedContainer: UnkeyedEncodingContainer {
    var count: Int {
        return 0
    }

    func encodeNil() throws {

    }
    
    func encode<T>(_ value: T) throws where T : Encodable {

    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        return _AMFEncoder.KeyedContainer<NestedKey>(codingPath: [], userInfo: [:]) as! KeyedEncodingContainer<NestedKey>
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        return _AMFEncoder.UnkeyedContainer(codingPath: [], userInfo: [:]) as! UnkeyedEncodingContainer
    }
    
    func superEncoder() -> Encoder {
        return _AMFEncoder()
    }
}

extension _AMFEncoder.UnkeyedContainer: AMFEncodingContainer {}
