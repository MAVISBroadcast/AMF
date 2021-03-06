import Foundation

extension _AMF0Encoder {
    final class SingleValueContainer {
        var data = Data()

        fileprivate var canEncodeNewValue = true
        fileprivate func checkCanEncode(value: Any?) throws {
            guard canEncodeNewValue else {
                let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Attempt to encode value through single value container when previously value already encoded.")
                throw EncodingError.invalidValue(value as Any, context)
            }
        }

        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]

        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
    }
}

extension _AMF0Encoder.SingleValueContainer: SingleValueEncodingContainer {
    func encodeNil() throws {
        data.append(AMF0Marker.null.rawValue)
    }

    func encode(_ value: Bool) throws {
        data.append(AMF0Marker.boolean.rawValue)
        data.append(value ? 0x01 : 0x00)
    }

    func encode(_ value: String) throws {
        if let encodeAsECMAArray = userInfo[AMF0Encoder.EncodeAsECMAArray] as? Bool, encodeAsECMAArray {
            if let doubleValue = Double(value), let encodeAsDouble = userInfo[AMF0Encoder.EncodeStringsAsNumbersIfDoublesInECMAArray] as? Bool, encodeAsDouble {
                return try encode(doubleValue)
            } else if let boolValue = Bool(value), let encodeAsBool = userInfo[AMF0Encoder.EncodeStringsAsBoolsIfTrueOrFalseInECMAArray] as? Bool, encodeAsBool {
                return try encode(boolValue)
            }
        }
        guard let stringData = value.data(using: .utf8) else {
            let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode string using UTF-8 encoding.")
            throw EncodingError.invalidValue(value, context)
        }
        let length = stringData.count
        if let uInt16Length = UInt16(exactly: length) {
            data.append(AMF0Marker.string.rawValue)
            data.append(contentsOf: uInt16Length.bytes())
            data.append(contentsOf: stringData)
        } else if let uInt32Length = UInt32(exactly: length) {
            data.append(AMF0Marker.longString.rawValue)
            data.append(contentsOf: uInt32Length.bytes())
            data.append(contentsOf: stringData)
        } else {
            let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode string with length \(length).")
            throw EncodingError.invalidValue(value, context)
        }
    }

    func encode(_ value: Double) throws {
        data.append(AMF0Marker.number.rawValue)
        data.append(contentsOf: value.bitPattern.bytes())
    }

    func encode(_ value: Float) throws {
        try encode(Double(value))
    }

    func encode(_ value: Int) throws {
        try encode(Double(value))
    }

    func encode(_ value: Int8) throws {
        try encode(Double(value))
    }

    func encode(_ value: Int16) throws {
        try encode(Double(value))
    }

    func encode(_ value: Int32) throws {
        try encode(Double(value))
    }

    func encode(_ value: Int64) throws {
        try encode(Double(value))
    }

    func encode(_ value: UInt) throws {
        try encode(Double(value))
    }

    func encode(_ value: UInt8) throws {
        try encode(Double(value))
    }

    func encode(_ value: UInt16) throws {
        try encode(Double(value))
    }

    func encode(_ value: UInt32) throws {
        try encode(Double(value))
    }

    func encode(_ value: UInt64) throws {
        try encode(Double(value))
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        try checkCanEncode(value: value)
        defer { canEncodeNewValue = false }

        switch value {
        case let data as Data:
            try encode(data)
        case let date as Date:
            try encode(date)
        default:
            let encoder = _AMF0Encoder()
            encoder.userInfo = userInfo
            try value.encode(to: encoder)
            data.append(encoder.data)
        }
    }

    func encode(_ value: Date) throws {
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }

        data.append(AMF0Marker.date.rawValue)
        data.append(contentsOf: (value.timeIntervalSince1970 * 1000).bitPattern.bytes())
        data.append(contentsOf: UInt16(0).bytes())
    }
}

extension _AMF0Encoder.SingleValueContainer: AMF0EncodingContainer {}
