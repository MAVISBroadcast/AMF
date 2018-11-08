//
//  AMF3ReferenceTable.swift
//  AMF
//
//  Created by James Hartt on 01/11/2018.
//

import Foundation

class AMF3DecodingReferenceTable {
    var decodingStringsTable: [String] = []
    var decodingComplexObjectsTable: [AMF3DecodingContainer] = []
    var decodingObjectTraitsTable: [AMF3TraitsInfo] = []
}

class AMF3EncodingReferenceTable {
    var encodingStringsTable: [String] = []
    var encodingComplexObjectsTable: [AMF3EncodingContainer] = []
    var encodingObjectTraitsTable: [AMF3TraitsInfo] = []
}
