//
//  AMFCommand.swift
//  AMF
//
//  Created by James Hartt on 01/11/2018.
//
import Foundation

struct AMFCommand: Codable {
    let commandName: String
    let transactionID: Double

    let commandObject: AMFCommandObject?

    public init(from decoder: Decoder) throws {
        let singleValueDecoder = try decoder.singleValueContainer()
        commandName = try singleValueDecoder.decode(String.self)
        transactionID = try singleValueDecoder.decode(Double.self)
        commandObject = try singleValueDecoder.decode(AMFCommandObject?.self)
    }

    struct AMFCommandObject: Codable {
        let fmsVer: String
        let capabilities: Double
        let mode: Double
    }
}
