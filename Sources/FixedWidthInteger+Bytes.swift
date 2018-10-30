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
}
