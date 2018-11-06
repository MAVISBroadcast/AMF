//
//  AMF3Markers.swift
//  AMF
//
//  Created by James Hartt on 30/10/2018.
//

import Foundation

enum AMF3Marker: UInt8 {
    case undefined = 0x00
    case null = 0x01
    case `false` = 0x02
    case `true` = 0x03
    case integer = 0x04
    case double = 0x05
    case string = 0x06
    case xmlDoc = 0x07
    case date = 0x08
    case array = 0x09
    case object = 0x0A
    case xml = 0x0B
    case byteArray = 0x0C
    case vectorInt = 0x0D
    case vectorUInt = 0x0E
    case vectorDouble = 0x0F
    case vectorObject = 0x10
    case dictionary = 0x11
}
