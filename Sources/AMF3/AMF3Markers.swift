//
//  AMF3Markers.swift
//  AMF
//
//  Created by James Hartt on 30/10/2018.
//

import Foundation

enum AMF3Marker: UInt8 {
    case number = 0x00
    case boolean = 0x01
    case string = 0x02
    case object = 0x03
    // case movieclip = 0x04 reserved, not supported
    case null = 0x05
    case undefined = 0x06
    case reference = 0x07
    case ecmaArray = 0x08
    case objectEnd = 0x09
    case strictArray = 0x0A
    case date = 0x0B
    case longString = 0x0C
    case unsupported = 0x0D
    // case recordSet = 0x0E reserved, not supported
    case xmlDocument = 0x0F
    case typedObject = 0x10
    case avmplusObject = 0x11
}
