//
//  AMF0ReferenceTable.swift
//  AMF
//
//  Created by James Hartt on 01/11/2018.
//

import Foundation

class AMF0DecodingReferenceTable {
    var decodingArray: [AMF0DecodingContainer] = []
}

class AMF0EncodingReferenceTable {
    var encodingLookup: [Int: (index: Int, AMF0EncodingContainer)] = [:]
}
