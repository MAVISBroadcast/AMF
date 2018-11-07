//
//  AMF3ReferenceTable.swift
//  AMF
//
//  Created by James Hartt on 01/11/2018.
//

import Foundation

class AMF3DecodingReferenceTable {
    var decodingStringsTable: [_AMF0Decoder.SingleValueContainer] = []
    var decodingComplexObjectsTable: [AMF3DecodingContainer] = []
    var decodingObjectTraitsTable: [AMF3DecodingContainer] = []
}

class AMF3EncodingReferenceTable {
    var encodingStringsTable: [String] = []
    var encodingComplexObjectsTable: [AMF3EncodingContainer] = []
    var encodingObjectTraitsTable: [AMF3EncodingContainer] = []
}
