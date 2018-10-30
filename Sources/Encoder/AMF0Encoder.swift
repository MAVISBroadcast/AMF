import Foundation

/**
 
 */
public class AMF0Encoder {
    func encode(_ value: Encodable) throws -> Data {
        let encoder = _AMF0Encoder()
        try value.encode(to: encoder)
        return encoder.data
    }
}

final class _AMF0Encoder {
    var codingPath: [CodingKey] = []
    
    var userInfo: [CodingUserInfoKey : Any] = [:]
    
    fileprivate var container: AMFEncodingContainer?

    var data = Data()
}

extension _AMF0Encoder: Encoder {
    fileprivate func assertCanCreateContainer() {
        precondition(self.container == nil)
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        assertCanCreateContainer()
        
        let container = KeyedContainer<Key>(codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        assertCanCreateContainer()
        
        let container = UnkeyedContainer(codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return container
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        assertCanCreateContainer()
        
        let container = SingleValueContainer(codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return container
    }
}

protocol AMFEncodingContainer: class {
    
}
