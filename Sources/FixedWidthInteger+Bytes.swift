//
//  FixedWidthInteger+Bytes.swift
//  AMF
//
//  Created by James Hartt on 30/10/2018.
//

import Foundation

extension FixedWidthInteger {
    init(bytes: [UInt8], endianess: Endianess) {
        self = bytes.withUnsafeBufferPointer {
            $0.baseAddress!.withMemoryRebound(to: Self.self, capacity: 1) {
                switch endianess {
                case .big:
                    return $0.pointee.bigEndian
                case .little:
                    return $0.pointee.littleEndian
                }
            }
        }
    }

    func bytes(endianess: Endianess = .big) -> [UInt8] {
        let capacity = MemoryLayout<Self>.size
        var mutableValue: Self = {
            switch endianess {
            case .big:
                return self.bigEndian
            case .little:
                return self.littleEndian
            }
        }()
        return withUnsafePointer(to: &mutableValue) {
            $0.withMemoryRebound(to: UInt8.self, capacity: capacity) {
                Array(UnsafeBufferPointer(start: $0, count: capacity))
            }
        }
    }
}
