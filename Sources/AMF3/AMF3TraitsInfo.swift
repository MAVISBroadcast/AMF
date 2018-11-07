//
//  AMF3TraitsInfo.swift
//  AMF
//
//  Created by James Hartt on 07/11/2018.
//

import Foundation

struct AMF3TraitsInfo {
    let className: String
    let dynamic: Bool
    let externalisable: Bool
    let count: UInt
    let properties: [String]

    func decodeTraits(ref: UInt32, data: Data) -> AMF3TraitsInfo? {
        return nil
    }
}
