import Foundation

extension _AMF0Decoder {
    final class UnkeyedContainer {
        var codingPath: [CodingKey]
        
        var nestedCodingPath: [CodingKey] {
            return self.codingPath + [AnyCodingKey(intValue: self.count ?? 0)!]
        }
        
        var userInfo: [CodingUserInfoKey: Any]
        
        var data: Data
        var index: Data.Index
        var referenceTable: ReferenceTable
        var format: AMF0Marker?
        
        lazy var count: Int? = {
            do {
                let format = try self.readByte()
                self.format = AMF0Marker(rawValue: format)

                switch format {
                case AMF0Marker.strictArray.rawValue:
                    return Int(try read(UInt32.self))
                case AMF0Marker.reference.rawValue:
                    return -1
                default:
                    return nil
                }
            } catch {
                return nil
            }

        }()
        
        var currentIndex: Int = 0
        
        lazy var nestedContainers: [AMF0DecodingContainer] = {

            guard let count = self.count else {
                return []
            }

            var nestedContainers: [AMF0DecodingContainer] = []

            do {
                for _ in 0..<count {
                    let container = try self.decodeContainer()
                    nestedContainers.append(container)
                }
            } catch {
//                fatalError() // FIXME
            }

            self.currentIndex = 0
            
            return nestedContainers
        }()
        
        init(data: Data, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any], referenceTable: ReferenceTable) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.data = data
            self.index = self.data.startIndex
            self.referenceTable = referenceTable
        }
        
        var isAtEnd: Bool {
            guard let count = self.count else {
                return true
            }
            return currentIndex >= count
        }
        
        func checkCanDecodeValue() throws {
            guard !self.isAtEnd || format == .null else {
                throw DecodingError.dataCorruptedError(in: self, debugDescription: "Unexpected end of data")
            }
        }
    }
}

extension _AMF0Decoder.UnkeyedContainer: UnkeyedDecodingContainer {

    func decodeNil() throws -> Bool {
        try checkCanDecodeValue()
        defer { self.currentIndex += 1 }

        let container = self.nestedContainers[self.currentIndex] as! _AMF0Decoder.SingleValueContainer
        let value = container.decodeNil()
        
        return value
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        try checkCanDecodeValue()

        defer { self.currentIndex += 1 }

        if format == .null {
            let singleValueContainer = _AMF0Decoder.SingleValueContainer(data: data, codingPath: codingPath, userInfo: userInfo, referenceTable: referenceTable)
            let decoder = _AMF0Decoder(data: singleValueContainer.data, referenceTable: self.referenceTable)
            let value = try T(from: decoder)

            return value
       }

        let container = self.nestedContainers[self.currentIndex]
        let decoder = _AMF0Decoder(data: container.data, referenceTable: self.referenceTable)
        let value = try T(from: decoder)
        
        return value
    }
    
    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        try checkCanDecodeValue()
        defer { self.currentIndex += 1 }

        let container = self.nestedContainers[self.currentIndex] as! _AMF0Decoder.UnkeyedContainer
        
        return container
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        try checkCanDecodeValue()
        defer { self.currentIndex += 1 }

        let container = self.nestedContainers[self.currentIndex] as! _AMF0Decoder.KeyedContainer<NestedKey>
        
        return KeyedDecodingContainer(container)
    }

    func superDecoder() throws -> Decoder {
        return _AMF0Decoder(data: self.data, referenceTable: self.referenceTable)
    }
}

extension _AMF0Decoder.UnkeyedContainer {
    func decodeContainer() throws -> AMF0DecodingContainer {
        try checkCanDecodeValue()
        
        defer { self.currentIndex += 1 }
        
        let startIndex = self.index
        
        let length: Int
        let rawFormat = try self.readByte()
        guard let format = AMF0Marker(rawValue: rawFormat) else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid format: \(String(describing: AMF0Marker(rawValue: rawFormat)))")
            throw DecodingError.typeMismatch(Double.self, context)
        }

        if format == .object || format == .strictArray || format == .typedObject || format == .ecmaArray {

        }

        switch format {
        case .object, .ecmaArray:
            let container = _AMF0Decoder.KeyedContainer<AnyCodingKey>(data: self.data.suffix(from: startIndex), codingPath: self.nestedCodingPath, userInfo: self.userInfo, referenceTable: self.referenceTable)
            referenceTable.decodingArray.append(container)
            _ = container.nestedContainers // FIXME
            self.index = container.index
            return container
        case .boolean:
            length = 1
        case .number:
            length = 8
        case .string:
            length = Int(try read(UInt16.self))
        case .reference:
            let reference = Int(try read(UInt16.self))
            return referenceTable.decodingArray[reference]
        default:
            throw DecodingError.dataCorruptedError(in: self, debugDescription: "Invalid format: \(format)")
        }

        let range: Range<Data.Index> = startIndex..<self.index.advanced(by: length)
        self.index = range.upperBound
        
        let container = _AMF0Decoder.SingleValueContainer(
            data: data.subdata(in: range),
            codingPath: codingPath,
            userInfo: userInfo,
            referenceTable: referenceTable
        )

        return container
    }
}

extension _AMF0Decoder.UnkeyedContainer: AMF0DecodingContainer {}
