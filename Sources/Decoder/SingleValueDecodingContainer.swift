import Foundation

extension _AMF0Decoder {
    final class SingleValueContainer {
        var data: Data
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var index: Data.Index
        var referenceTable: ReferenceTable

        init(data: Data, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any], referenceTable: ReferenceTable) {
            self.data = data
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.index = self.data.startIndex
            self.referenceTable = referenceTable
        }

        var length: Int? {
            do {
                let rawFormat = try readByte()
                if let format = AMF0Marker(rawValue: rawFormat) {
                    switch format {
                    case AMF0Marker.boolean:
                        return 1 + 1 // marker + one byte
                    case AMF0Marker.string:
                        return 1 + 2 + Int(try read(UInt16.self)) // marker + length UInt16 + actual length of string
                    case AMF0Marker.longString:
                        return 1 + 4 + Int(try read(UInt16.self)) // marker + length UInt32 + actual length of string
                    case AMF0Marker.number:
                        return 1 + 8 // marker + IEEE 754 DOUBLE
                    case AMF0Marker.date:
                        return 1 + 8 + 2 // marker + IEEE 754 DOUBLE + unused UInt16 time zone int
                    default:
                        return nil
                    }
                }
                return nil
            } catch {
                return nil
            }
        }
    }
}

extension _AMF0Decoder.SingleValueContainer: SingleValueDecodingContainer {

    func decodeNil() -> Bool {
        do {
            let format = try readByte()
            switch format {
            case AMF0Marker.null.rawValue, AMF0Marker.undefined.rawValue:
                return true
            default:
                return false
            }
        } catch {
            return false
        }
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        let format = try readByte()
        switch format {
        case AMF0Marker.boolean.rawValue:
            let booleanValue = try readByte()
            return booleanValue > 0x00
        default:
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid format: \(String(describing: AMF0Marker(rawValue: format)))")
            throw DecodingError.typeMismatch(Double.self, context)
        }
    }
    
    func decode(_ type: String.Type) throws -> String {
        let format = try readByte()
        switch format {
        case AMF0Marker.string.rawValue:
            let length: UInt16 = try read(UInt16.self)
            let utfData = try read(Int(length))
            guard let string = String(data: utfData, encoding: .utf8) else {
                let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot load string")
                throw DecodingError.dataCorrupted(context)
            }
            return string
        case AMF0Marker.longString.rawValue:
            let length: UInt32 = try read(UInt32.self)
            let utfData = try read(Int(length))
            guard let string = String(data: utfData, encoding: .utf8) else {
                let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot load string")
                throw DecodingError.dataCorrupted(context)
            }
            return string
        default:
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid format: \(String(describing: AMF0Marker(rawValue: format)))")
            throw DecodingError.typeMismatch(Double.self, context)
        }
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        let format = try readByte()
        switch format {
        case AMF0Marker.number.rawValue:
            return try Double(bitPattern: read(UInt64.self))
        case AMF0Marker.date.rawValue:
            let date = try Double(bitPattern: read(UInt64.self))
            let difference = Double(978307200) // Difference between 01/01/1970 and 01/01/2001
            return date - difference
        default:
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid format: \(String(describing: AMF0Marker(rawValue: format)))")
            throw DecodingError.typeMismatch(Double.self, context)
        }
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        return 0
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        return 0
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        return 0
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        return 0
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        return 0
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        return 0
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        return 0
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        return 0
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        return 0
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        return 0
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        return 0
    }
  
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let decoder = _AMF0Decoder(data: self.data, referenceTable: self.referenceTable)
        let value = try T(from: decoder)
        if let nextIndex = decoder.container?.index {
            self.index = nextIndex
        }

        return value
    }
}

extension _AMF0Decoder.SingleValueContainer: AMF0DecodingContainer {}
