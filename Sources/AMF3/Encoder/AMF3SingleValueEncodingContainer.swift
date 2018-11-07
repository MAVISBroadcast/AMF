import Foundation

extension _AMF3Encoder {
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
        var referenceTable: AMF3EncodingReferenceTable

        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any], referenceTable: AMF3EncodingReferenceTable) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.referenceTable = referenceTable
        }
    }
}

extension _AMF3Encoder.SingleValueContainer: SingleValueEncodingContainer {
    func encodeNil() throws {
        data.append(AMF3Marker.null.rawValue)
    }

    func encode(_ value: Bool) throws {
        if value {
            data.append(AMF3Marker.true.rawValue)
        } else {
            data.append(AMF3Marker.false.rawValue)
        }
    }

    func encode(_ value: String) throws {
        guard let stringData = value.data(using: .utf8) else {
            let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode string using UTF-8 encoding.")
            throw EncodingError.invalidValue(value, context)
        }
        let length = stringData.count
        if let length = UInt32(exactly: length) {

            data.append(AMF3Marker.string.rawValue)
            let bitShiftedLength = (length << 1) | 1
            data.append(contentsOf: try bitShiftedLength.variableBytes())
            data.append(contentsOf: stringData)
        } else {
            let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode string with length \(length).")
            throw EncodingError.invalidValue(value, context)
        }
    }

    func encode(_ value: Double) throws {
        data.append(AMF3Marker.double.rawValue)
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
            let encoder = _AMF3Encoder()
            try value.encode(to: encoder)
            data.append(encoder.data)
        }
    }

    func encode(_ value: Date) throws {
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }

        data.append(AMF3Marker.date.rawValue)
        data.append(contentsOf: (value.timeIntervalSince1970 * 1000).bitPattern.bytes())
    }
}

extension _AMF3Encoder.SingleValueContainer: AMF3EncodingContainer {}
