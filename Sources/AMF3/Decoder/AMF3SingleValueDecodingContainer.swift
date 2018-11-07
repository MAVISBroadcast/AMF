import Foundation

extension _AMF3Decoder {
    final class SingleValueContainer {
        var data: Data
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var index: Data.Index
        var referenceTable: AMF3DecodingReferenceTable

        init(data: Data, codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any], referenceTable: AMF3DecodingReferenceTable) {
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
                    case AMF3Marker.true:
                        return 1
                    case AMF3Marker.false:
                        return 1
                    case AMF3Marker.string:
                        let length = UInt32(variableBytes: data[index...])
                        if let variableLength = length.variableLength {
                            defer { index += variableLength }
                            return 1 + variableLength + Int(length) // marker + length of variable int + actual length of string
                        }
                    case AMF3Marker.double:
                        return 1 + 8 // marker + IEEE 754 DOUBLE
                    case AMF3Marker.date:
                        return 1 + 8 // marker + IEEE 754 DOUBLE
                    case AMF3Marker.null, AMF3Marker.undefined:
                        return 1
                    case AMF3Marker.integer:
                        let length = UInt32(variableBytes: data[index...])
                        if let variableLength = length.variableLength {
                            defer { index += variableLength }
                            return 1 + variableLength
                        }
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
        case AMF3Marker.true.rawValue:
            return true
        case AMF3Marker.false.rawValue:
            return false
        default:
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Invalid format: \(String(describing: AMF3Marker(rawValue: format)))")
            throw DecodingError.typeMismatch(Double.self, context)
        }
    }

    func decode(_: String.Type) throws -> String {
        let format = try readByte()
        switch format {
        case AMF3Marker.string.rawValue:
            let potentialReference = UInt32(variableBytes: data[index...])
            let bitShiftedIndexOrLength = Int(potentialReference >> 1)
            if potentialReference & 1 == 0 {
                let string = referenceTable.decodingStringsTable[bitShiftedIndexOrLength]
                return string
            } else {
                index += potentialReference.variableLength ?? 0
                let utfData = try read(bitShiftedIndexOrLength)
                guard let string = String(data: utfData, encoding: .utf8) else {
                    let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot load string")
                    throw DecodingError.dataCorrupted(context)
                }
                referenceTable.decodingStringsTable.append(string)
                return string
            }
        default:
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Invalid format: \(String(describing: AMF3Marker(rawValue: format)))")
            throw DecodingError.typeMismatch(Double.self, context)
        }
    }

    func decode(_: Double.Type) throws -> Double {
        let format = try readByte()
        switch format {
        case AMF3Marker.double.rawValue:
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
