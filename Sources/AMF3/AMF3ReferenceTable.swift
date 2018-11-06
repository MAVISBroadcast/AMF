//
//  AMF3ReferenceTable.swift
//  AMF
//
//  Created by James Hartt on 01/11/2018.
//

import Foundation

class AMF3DecodingReferenceTable {
    var decodingArray: [AMF3DecodingContainer] = []
}

class AMF3EncodingReferenceTable {
    var encodingLookup: [Int: (index: Int, AMF3EncodingContainer)] = [:]
}
