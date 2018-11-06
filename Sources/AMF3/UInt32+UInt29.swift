//
//  UInt32+UInt29.swift
//  AMF
//
//  Created by James Hartt on 06/11/2018.
//

import Foundation

typealias UInt29 = UInt32

enum UInt29Error: Error {
    case integerTooLarge
}

extension UInt32 {
    init(variableBytes: Data) {
        var iterator = variableBytes.makeIterator()
        var value: UInt32
        var byte = (iterator.next() ?? 0x00) & 0xFF

        if byte < 128 {
            self = UInt32(byte)
            return
        }

        value = (UInt32(byte & 0x7F) << 7)
        byte = (iterator.next() ?? 0x00) & 0xFF
        if byte < 128 {
            self = value | UInt32(byte)
            return
        }

        value = (value | UInt32(byte & 0x7F)) << 7
        byte = (iterator.next() ?? 0x00) & 0xFF
        if byte < 128 {
            self = value | UInt32(byte)
            return
        }

        value = (value | UInt32(byte & 0x7F)) << 8
        byte = (iterator.next() ?? 0x00) & 0xFF
        self = value | UInt32(byte)
    }

    func variableBytes() throws -> [UInt8] {
        let value = self & 0x1FFF_FFFF
        if value != self {
            throw UInt29Error.integerTooLarge
        }
        if value < 0x80 {
            return [UInt8(value)]
        } else if value < 0x4000 {
            return [
                UInt8(((value >> 7) & 0x7F) | 0x80),
                (UInt8(value & 0x7F)),
            ]
        } else if value < 0x200000 {
            return [
                UInt8(((value >> 14) & 0x7F) | 0x80),
                UInt8(((value >> 7) & 0x7F) | 0x80),
                UInt8(value & 0x7F),
            ]
        } else {
            return [
                UInt8(((value >> 22) & 0x7F) | 0x80),
                UInt8(((value >> 15) & 0x7F) | 0x80),
                UInt8(((value >> 8) & 0x7F) | 0x80),
                UInt8(value & 0xFF),
            ]
        }
    }

    var variableLength: Int? {
        switch self {
        case 0x0000_0000 ... 0x0000_007F:
            return 1
        case 0x0000_0080 ... 0x0000_3FFF:
            return 2
        case 0x0000_4000 ... 0x001F_FFFF:
            return 3
        case 0x0020_0000 ... 0x3FFF_FFFF:
            return 4
        case 0x4000_0000 ... 0xFFFF_FFFF:
            return nil
        default:
            return nil
        }
    }
}
