import Foundation

extension _AMF3Decoder {
    final class SingleValueContainer {
        var data: Data
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var index: Data.Index
        var referenceTable: DecodingReferenceTable

        init(data: Data, codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any], referenceTable: DecodingReferenceTable) {
            self.data = data
            self.codingPath = codingPath
            self.userInfo = userInfo
            index = self.data.startIndex
            self.referenceTable = referenceTable
        }

        var length: Int? {
            do {
                let rawFormat = try readByte()
                if let format = AMF3Marker(rawValue: rawFormat) {
                    switch format {
                    case AMF3Marker.boolean:
                        return 1 + 1 // marker + one byte
                    case AMF3Marker.string:
                        return 1 + 2 + Int(try read(UInt16.self)) // marker + length UInt16 + actual length of string
                    case AMF3Marker.longString:
                        return 1 + 4 + Int(try read(UInt16.self)) // marker + length UInt32 + actual length of string
                    case AMF3Marker.number:
                        return 1 + 8 // marker + IEEE 754 DOUBLE
                    case AMF3Marker.date:
                        return 1 + 8 + 2 // marker + IEEE 754 DOUBLE + unused UInt16 time zone int
                    case AMF3Marker.null, AMF3Marker.undefined:
                        return 1
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

extension _AMF3Decoder.SingleValueContainer: SingleValueDecodingContainer {
    func decodeNil() -> Bool {
        do {
            let format = try readByte()
            switch format {
            case AMF3Marker.null.rawValue, AMF3Marker.undefined.rawValue:
                return true
            default:
                return false
            }
        } catch {
            return false
        }
    }

    func decode(_: Bool.Type) throws -> Bool {
        let format = try readByte()
        switch format {
        case AMF3Marker.boolean.rawValue:
            let booleanValue = try readByte()
            return booleanValue > 0x00
        default:
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Invalid format: \(String(describing: AMF3Marker(rawValue: format)))")
            throw DecodingError.typeMismatch(Double.self, context)
        }
    }

    func decode(_: String.Type) throws -> String {
        let format = try readByte()
        switch format {
        case AMF3Marker.string.rawValue:
            let length: UInt16 = try read(UInt16.self)
            let utfData = try read(Int(length))
            guard let string = String(data: utfData, encoding: .utf8) else {
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot load string")
                throw DecodingError.dataCorrupted(context)
            }
            return string
        case AMF3Marker.longString.rawValue:
            let length: UInt32 = try read(UInt32.self)
            let utfData = try read(Int(length))
            guard let string = String(data: utfData, encoding: .utf8) else {
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot load string")
                throw DecodingError.dataCorrupted(context)
            }
            return string
        default:
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Invalid format: \(String(describing: AMF3Marker(rawValue: format)))")
            throw DecodingError.typeMismatch(Double.self, context)
        }
    }

    func decode(_: Double.Type) throws -> Double {
        let format = try readByte()
        switch format {
        case AMF3Marker.number.rawValue:
            return try Double(bitPattern: read(UInt64.self))
        case AMF3Marker.date.rawValue:
            let date = try Double(bitPattern: read(UInt64.self))
            let difference = Double(978_307_200) // Difference between 01/01/1970 and 01/01/2001
            return date - difference
        default:
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Invalid format: \(String(describing: AMF3Marker(rawValue: format)))")
            throw DecodingError.typeMismatch(Double.self, context)
        }
    }

    func decode(_ type: Float.Type) throws -> Float {
        let double = try decode(Double.self)
        let exactValue = type.init(exactly: double)
        return try unoptional(optional: exactValue)
    }

    func decode(_ type: Int.Type) throws -> Int {
        let double = try decode(Double.self)
        let exactValue = type.init(exactly: double)
        return try unoptional(optional: exactValue)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        let double = try decode(Double.self)
        let exactValue = type.init(exactly: double)
        return try unoptional(optional: exactValue)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        let double = try decode(Double.self)
        let exactValue = type.init(exactly: double)
        return try unoptional(optional: exactValue)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        let double = try decode(Double.self)
        let exactValue = type.init(exactly: double)
        return try unoptional(optional: exactValue)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        let double = try decode(Double.self)
        let exactValue = type.init(exactly: double)
        return try unoptional(optional: exactValue)
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        let double = try decode(Double.self)
        let exactValue = type.init(exactly: double)
        return try unoptional(optional: exactValue)
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        let double = try decode(Double.self)
        let exactValue = type.init(exactly: double)
        return try unoptional(optional: exactValue)
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        let double = try decode(Double.self)
        let exactValue = type.init(exactly: double)
        return try unoptional(optional: exactValue)
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        let double = try decode(Double.self)
        let exactValue = type.init(exactly: double)
        return try unoptional(optional: exactValue)
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        let double = try decode(Double.self)
        let exactValue = type.init(exactly: double)
        return try unoptional(optional: exactValue)
    }

    private func unoptional<T>(optional: T?) throws -> T {
        if let value = optional {
            return value
        } else {
            let type = Swift.type(of: optional)
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Could not represent Double number in: \(type)")
            throw DecodingError.typeMismatch(Double.self, context)
        }
    }

    func decode<T>(_: T.Type) throws -> T where T: Decodable {
        let decoder = _AMF3Decoder(data: data, referenceTable: referenceTable)
        let value = try T(from: decoder)
        if let nextIndex = decoder.container?.index {
            index = nextIndex
        }

        return value
    }
}

extension _AMF3Decoder.SingleValueContainer: AMF3DecodingContainer {}
