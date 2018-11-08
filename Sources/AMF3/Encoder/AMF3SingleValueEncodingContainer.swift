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
        var supressMarkerEncoding: Bool = false

        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any], referenceTable: AMF3EncodingReferenceTable) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.referenceTable = referenceTable
        }
    }
}

extension _AMF3Encoder.SingleValueContainer: SingleValueEncodingContainer {
    func encodeNil() throws {
        encodeMarker(marker: .null)
    }

    func encode(_ value: Bool) throws {
        if value {
            encodeMarker(marker: .true)
        } else {
            encodeMarker(marker: .false)
        }
    }

    func encode(_ value: String) throws {
        guard let stringData = value.data(using: .utf8) else {
            let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode string using UTF-8 encoding.")
            throw EncodingError.invalidValue(value, context)
        }
        let length = stringData.count
        if let length = UInt32(exactly: length) {
            encodeMarker(marker: .string)
            let bitShiftedLength = (length << 1) | 1
            data.append(contentsOf: try bitShiftedLength.variableBytes())
            data.append(contentsOf: stringData)
        } else {
            let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode string with length \(length).")
            throw EncodingError.invalidValue(value, context)
        }
    }

    func encode(_ value: Double) throws {
        encodeMarker(marker: .double)
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

    func encode(_ value: Data) throws {
        data.append(contentsOf: value)
    }

    func encode(_ value: Date) throws {
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }

        encodeMarker(marker: .date)
        data.append(contentsOf: (value.timeIntervalSince1970 * 1000).bitPattern.bytes())
    }

    func encodeMarker(marker: AMF3Marker) {
        guard supressMarkerEncoding == false else {
            return
        }
        data.append(marker.rawValue)
    }
}

extension _AMF3Encoder.SingleValueContainer: AMF3EncodingContainer {}
