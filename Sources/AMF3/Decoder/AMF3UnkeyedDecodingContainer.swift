import Foundation

extension _AMF3Decoder {
    final class UnkeyedContainer {
        var codingPath: [CodingKey]

        var nestedCodingPath: [CodingKey] {
            return codingPath + [AnyCodingKey(intValue: self.count ?? 0)!]
        }

        var userInfo: [CodingUserInfoKey: Any]

        var data: Data
        var index: Data.Index
        var referenceTable: AMF3DecodingReferenceTable
        var marker: AMF3Marker?

        lazy var count: Int? = {
            do {
                let marker = try self.readByte()
                self.marker = AMF3Marker(rawValue: marker)

                switch marker {
                case AMF3Marker.array.rawValue:
                    let potentialReference = UInt32(variableBytes: data[index...])
                    let bitShiftedIndexOrLength = Int(potentialReference >> 1)
                    defer{ index += potentialReference.variableLength ?? 0 }
                    if potentialReference & 1 == 0 {
                        let decoderContainer = referenceTable.decodingComplexObjectsTable[bitShiftedIndexOrLength] as? _AMF3Decoder.UnkeyedContainer
                        return decoderContainer?.count
                    } else {
                        return bitShiftedIndexOrLength
                    }
                default:
                    return nil
                }
            } catch {
                return nil
            }

        }()

        var currentIndex: Int = 0

        lazy var nestedContainers: [AMF3DecodingContainer] = {
            guard let count = self.count else {
                return []
            }

            var nestedContainers: [AMF3DecodingContainer] = []

            guard try! readByte() == 0x01 else {
                fatalError() // Cannot support ECMA Array
            }

            do {
                for _ in 0 ..< count {
                    let container = try self.decodeContainer()
                    nestedContainers.append(container)
                }
            } catch {
                fatalError() // FIXME:
            }

            self.currentIndex = 0

            return nestedContainers
        }()

        init(data: Data, codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any], referenceTable: AMF3DecodingReferenceTable) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.data = data
            index = self.data.startIndex
            self.referenceTable = referenceTable
        }

        var isAtEnd: Bool {
            guard let count = self.count else {
                return true
            }
            return currentIndex >= count
        }

        func checkCanDecodeValue() throws {
            guard !isAtEnd || marker == .null else {
                throw DecodingError.dataCorruptedError(in: self, debugDescription: "Unexpected end of data")
            }
        }
    }
}

extension _AMF3Decoder.UnkeyedContainer: UnkeyedDecodingContainer {
    func decodeNil() throws -> Bool {
        try checkCanDecodeValue()
        defer { self.currentIndex += 1 }

        let container = nestedContainers[self.currentIndex] as! _AMF3Decoder.SingleValueContainer
        let value = container.decodeNil()

        return value
    }

    func decode<T>(_: T.Type) throws -> T where T: Decodable {
        try checkCanDecodeValue()

        defer { self.currentIndex += 1 }

        if marker == .null {
            let singleValueContainer = _AMF3Decoder.SingleValueContainer(data: data, codingPath: codingPath, userInfo: userInfo, referenceTable: referenceTable)
            let decoder = _AMF3Decoder(data: singleValueContainer.data, referenceTable: referenceTable)
            let value = try T(from: decoder)

            return value
        }

        let container = nestedContainers[self.currentIndex]
        let decoder = _AMF3Decoder(data: container.data, referenceTable: referenceTable)
        let value = try T(from: decoder)

        return value
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        try checkCanDecodeValue()
        defer { self.currentIndex += 1 }

        let container = nestedContainers[self.currentIndex] as! _AMF3Decoder.UnkeyedContainer

        return container
    }

    func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        try checkCanDecodeValue()
        defer { self.currentIndex += 1 }

        let container = nestedContainers[self.currentIndex] as! _AMF3Decoder.KeyedContainer<NestedKey>

        return KeyedDecodingContainer(container)
    }

    func superDecoder() throws -> Decoder {
        return _AMF3Decoder(data: data, referenceTable: referenceTable)
    }
}

extension _AMF3Decoder.UnkeyedContainer {
    func decodeContainer() throws -> AMF3DecodingContainer {
        try checkCanDecodeValue()

        defer { self.currentIndex += 1 }

        let startIndex = index

        let length: Int
        let rawFormat = try readByte()
        guard let marker = AMF3Marker(rawValue: rawFormat) else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Invalid marker: \(String(describing: AMF3Marker(rawValue: rawFormat)))")
            throw DecodingError.typeMismatch(Double.self, context)
        }

        switch marker {
        case .object:
            let container = _AMF3Decoder.KeyedContainer<AnyCodingKey>(data: data.suffix(from: startIndex), codingPath: nestedCodingPath, userInfo: userInfo, referenceTable: referenceTable)
            referenceTable.decodingComplexObjectsTable.append(container)
            _ = container.nestedContainers // FIXME:
            index = container.index
            return container
        case .true, .false:
            length = 0
        case .double:
            length = 8
        case .string:
            let variableUInt = UInt32(variableBytes: data[index...])
            let variableLength = variableUInt.variableLength!
            length = variableLength + Int(variableUInt >> 1) // length of variable int + actual length of string
        default:
            throw DecodingError.dataCorruptedError(in: self, debugDescription: "Invalid marker: \(marker)")
        }

        let range: Range<Data.Index> = startIndex ..< index.advanced(by: length)
        index = range.upperBound

        let container = _AMF3Decoder.SingleValueContainer(
            data: data[range],
            codingPath: codingPath,
            userInfo: userInfo,
            referenceTable: referenceTable
        )

        return container
    }
}

extension _AMF3Decoder.UnkeyedContainer: AMF3DecodingContainer {}
