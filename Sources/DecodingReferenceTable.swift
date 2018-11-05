//
//  ReferenceTable.swift
//  AMF
//
//  Created by James Hartt on 01/11/2018.
//

import Foundation

class DecodingReferenceTable {
    var decodingArray: [AMF0DecodingContainer] = []
}

class EncodingReferenceTable {
    var encodingLookup: [Int: (index: Int, AMF0EncodingContainer)] = [:]
}
