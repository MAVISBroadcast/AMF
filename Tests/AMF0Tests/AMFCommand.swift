//
//  AMFProperties.swift
//  AMF
//
//  Created by James Hartt on 01/11/2018.
//
import Foundation

struct AMFProperties: Codable {
    let fmsVer: String
    let capabilities: Double
    let mode: Double
}

struct AMFInformation: Codable {
    let level: String
    let code: String
    let description: String
    let clientId: Double
    let objectEncoding: Double
    let data: AMFInformationData
}

struct AMFInformationData: Codable {
    let version: String
}
