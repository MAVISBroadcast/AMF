import XCTest
@testable import AMF

class AMF0DecodingTests: XCTestCase {
    var decoder: AMF0Decoder!
    
    override func setUp() {
        self.decoder = AMF0Decoder()
    }

    func testDecodeTrueBoolean() {
        let value = try! decoder.decode(Bool.self, from: Data(bytes: [AMF0Marker.boolean.rawValue, 0x01]))
        XCTAssertEqual(value, true)
    }

    func testDecodeFalseBoolean() {
        let value = try! decoder.decode(Bool.self, from: Data(bytes: [AMF0Marker.boolean.rawValue, 0x00]))
        XCTAssertEqual(value, false)
    }

    func testDecodeDouble() {
        let value = try! decoder.decode(Double.self, from: Data(bytes: [AMF0Marker.number.rawValue, 0x40, 0x09, 0x21, 0xF9, 0xF0, 0x1B, 0x86, 0x6E]))
        XCTAssertEqual(value, 3.14159)
    }

    func testDecodeString() {
        let data = Data(bytes: [AMF0Marker.string.rawValue, /* big endian length of 5*/ 0x00, 0x05, /* UTF8 chars */ 0x68, 0x65, 0x6C, 0x6C, 0x6F])
        let value = try! decoder.decode(String.self, from: data)
        XCTAssertEqual(value, "hello")
    }

    func testDecodeEmoji() {
        let data = Data(bytes: [AMF0Marker.string.rawValue, /* big endian length of 20*/ 0x00, 0x14, 0xF0, 0x9F, 0x98, 0x80, 0xF0, 0x9F, 0x98, 0x83, 0xF0, 0x9F, 0x98, 0x84, 0xF0, 0x9F, 0x98, 0x81, 0xF0, 0x9F, 0x98, 0x86])
        let value = try! decoder.decode(String.self, from: data)
        XCTAssertEqual(value, "😀😃😄😁😆")
    }

    func testDecodeEmptyString() {
        let data = Data(bytes: [AMF0Marker.string.rawValue, /* big endian length of 0*/ 0x00, 0x00])
        let value = try! decoder.decode(String.self, from: data)
        XCTAssertEqual(value, "")
    }

    func testDictionary() {
        let data = Data(bytes: [AMF0Marker.object.rawValue, /*string length: 1*/ 0x00, 0x01, /* a */ 0x61, AMF0Marker.string.rawValue, /*string length: 1*/ 0x00, 0x01, /* a */ 0x61, /* empty UTF-8 */ 0x00, 0x00, AMF0Marker.objectEnd.rawValue])
        let value = try! decoder.decode([String: String].self, from: data)
        XCTAssertEqual(value, ["a": "a"])
    }

    func testEmptyArray() {
        let data = Data(bytes: [AMF0Marker.strictArray.rawValue, /*count: 0*/ 0x00, 0x00, 0x00, 0x00])
        let value = try! decoder.decode([String].self, from: data)
        XCTAssertEqual(value, [])
    }

    func testArray() {
        let data = Data(bytes: [AMF0Marker.strictArray.rawValue, /*count: 1*/ 0x00, 0x00, 0x00, 0x01, AMF0Marker.string.rawValue, /* big endian length of 5*/ 0x00, 0x05, /* UTF8 chars */ 0x68, 0x65, 0x6C, 0x6C, 0x6F])
        let value = try! decoder.decode([String].self, from: data)
        XCTAssertEqual(value, ["hello"])
    }

    func testDictionaryWithArrayInIt() {
        let data = Data(bytes: [AMF0Marker.object.rawValue, /*string length: 1*/ 0x00, 0x01, /* a */ 0x61, AMF0Marker.strictArray.rawValue, /*count: 1*/ 0x00, 0x00, 0x00, 0x01, AMF0Marker.string.rawValue, /* big endian length of 5*/ 0x00, 0x05, /* UTF8 chars */ 0x68, 0x65, 0x6C, 0x6C, 0x6F, /* empty UTF-8 */ 0x00, 0x00, AMF0Marker.objectEnd.rawValue])
        let value = try! decoder.decode([String: [String]].self, from: data)
        XCTAssertEqual(value, ["a": ["hello"]])
    }

    func testDecodeNil() {
        let data = Data(bytes: [AMF0Marker.null.rawValue])
        let value = try! decoder.decode(String?.self, from: data)
        XCTAssertNil(value)
    }

    func testECMAArray() {
        let data = Data(bytes: [AMF0Marker.ecmaArray.rawValue, /*count: 1*/ 0x00, 0x00, 0x00, 0x01, /*string length: 1*/ 0x00, 0x01, /* a */ 0x61, AMF0Marker.string.rawValue, /*string length: 1*/ 0x00, 0x01, /* a */ 0x61, /* empty UTF-8 */ 0x00, 0x00, AMF0Marker.objectEnd.rawValue])
        let value = try! decoder.decode([String: String].self, from: data)
        XCTAssertEqual(value, ["a": "a"])
    }

    func testLongString() {
        let data = Data(bytes: [AMF0Marker.longString.rawValue, /* big endian length of 5*/ 0x00, 0x00, 0x00, 0x05, /* UTF8 chars */ 0x68, 0x65, 0x6C, 0x6C, 0x6F])
        let value = try! decoder.decode(String.self, from: data)
        XCTAssertEqual(value, "hello")
    }

    func testDate() {
        let data = Data(bytes: [AMF0Marker.date.rawValue, 0x41, 0xD6, 0xF6, 0x78, 0x1F, 0x00, 0x00, 0x00, 0x00, 0x00])
        let value = try! decoder.decode(Date.self, from: data)
        XCTAssertEqual(value.timeIntervalSince1970, 1541005436)
    }

    func testReference() {
        let data = Data(bytes: [AMF0Marker.strictArray.rawValue, /*count: 1*/ 0x00, 0x00, 0x00, 0x02, AMF0Marker.object.rawValue, /*string length: 1*/ 0x00, 0x01, /* a */ 0x61, AMF0Marker.strictArray.rawValue, /*count: 1*/ 0x00, 0x00, 0x00, 0x01, AMF0Marker.string.rawValue, /* big endian length of 5*/ 0x00, 0x05, /* UTF8 chars */ 0x68, 0x65, 0x6C, 0x6C, 0x6F, /* empty UTF-8 */ 0x00, 0x00, AMF0Marker.objectEnd.rawValue, AMF0Marker.reference.rawValue, /* second object as reference */ 0x00, 0x01])
        let value = try! decoder.decode([[String: [String]]].self, from: data)
        XCTAssertEqual(value, [["a": ["hello"]], ["a": ["hello"]]])
    }

    func testAMFObject() {
        // The below is AMF0 lifted from https://en.wikipedia.org/wiki/Real-Time_Messaging_Protocol#Packet_structure it is the AMF0 portion of an RTMP message
        let data = Data(bytes: [0x02, 0x00, 0x0C, 0x63, 0x72, 0x65, 0x61, 0x74, 0x65, 0x53, 0x74, 0x72, 0x65, 0x61, 0x6D, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05])
        let value = try? decoder.decode(String.self, from: data)
        XCTAssertEqual(value, "createStream")
        XCTAssertEqual(decoder.finishedIndex, 15)
        let transactionID = try? decoder.decode(Double.self, from: data[decoder.finishedIndex...])
        XCTAssertEqual(transactionID, 2.0)
        XCTAssertEqual(decoder.finishedIndex, 24)
        let firstObject = try? decoder.decode(AMFCommand.self, from: data[decoder.finishedIndex...])
        XCTAssertNil(firstObject)
        XCTAssertEqual(decoder.finishedIndex, 25)
    }

    func testLargerAMFObject() {
        // The below is AMF0 lifted from https://en.wikipedia.org/wiki/Action_Message_Format it is the AMF0 portion of an RTMP message
        let data = Data(bytes: [0x02, 0x00, 0x07, 0x5F, 0x72, 0x65, 0x73, 0x75, 0x6C, 0x74, 0x00, 0x3F, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x06, 0x66, 0x6D, 0x73, 0x56, 0x65, 0x72, 0x02, 0x00, 0x0E, 0x46, 0x4D, 0x53, 0x2F, 0x33, 0x2C, 0x35, 0x2C, 0x35, 0x2C, 0x32, 0x30, 0x30, 0x34, 0x00, 0x0C, 0x63, 0x61, 0x70, 0x61, 0x62, 0x69, 0x6C, 0x69, 0x74, 0x69, 0x65, 0x73, 0x00, 0x40, 0x3F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x6D, 0x6F, 0x64, 0x65, 0x00, 0x3F, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x03, 0x00, 0x05, 0x6C, 0x65, 0x76, 0x65, 0x6C, 0x02, 0x00, 0x06, 0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x00, 0x04, 0x63, 0x6F, 0x64, 0x65, 0x02, 0x00, 0x1D, 0x4E, 0x65, 0x74, 0x43, 0x6F, 0x6E, 0x6E, 0x65, 0x63, 0x74, 0x69, 0x6F, 0x6E, 0x2E, 0x43, 0x6F, 0x6E, 0x6E, 0x65, 0x63, 0x74, 0x2E, 0x53, 0x75, 0x63, 0x63, 0x65, 0x73, 0x73, 0x00, 0x0B, 0x64, 0x65, 0x73, 0x63, 0x72, 0x69, 0x70, 0x74, 0x69, 0x6F, 0x6E, 0x02, 0x00, 0x15, 0x43, 0x6F, 0x6E, 0x6E, 0x65, 0x63, 0x74, 0x69, 0x6F, 0x6E, 0x20, 0x73, 0x75, 0x63, 0x63, 0x65, 0x65, 0x64, 0x65, 0x64, 0x2E, 0x00, 0x04, 0x64, 0x61, 0x74, 0x61, 0x08, 0x00, 0x00, 0x00, 0x01, 0x00, 0x07, 0x76, 0x65, 0x72, 0x73, 0x69, 0x6F, 0x6E, 0x02, 0x00, 0x0A, 0x33, 0x2C, 0x35, 0x2C, 0x35, 0x2C, 0x32, 0x30, 0x30, 0x34, 0x00, 0x00, 0x09, 0x00, 0x08, 0x63, 0x6C, 0x69, 0x65, 0x6E, 0x74, 0x49, 0x64, 0x00, 0x41, 0xD7, 0x9B, 0x78, 0x7C, 0xC0, 0x00, 0x00, 0x00, 0x0E, 0x6F, 0x62, 0x6A, 0x65, 0x63, 0x74, 0x45, 0x6E, 0x63, 0x6F, 0x64, 0x69, 0x6E, 0x67, 0x00, 0x40, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09])
        let value = try? decoder.decode(String.self, from: data)
        XCTAssertEqual(value, "_result")
        let transactionID = try? decoder.decode(Double.self, from: data[decoder.finishedIndex...])
        XCTAssertEqual(transactionID, 1)
        let firstObject = try? decoder.decode(AMFCommand.self, from: data[decoder.finishedIndex...])
        XCTAssertEqual(firstObject?.fmsVer, "FMS/3,5,5,2004")
        XCTAssertEqual(firstObject?.capabilities, 31.0)
        XCTAssertEqual(firstObject?.mode, 1.0)
        let secondObject = try? decoder.decode(AMFLevel.self, from: data[decoder.finishedIndex...])
        XCTAssertEqual(secondObject?.clientId, 1584259571)
        XCTAssertEqual(secondObject?.code, "NetConnection.Connect.Success")
        XCTAssertEqual(secondObject?.level, "status")
        XCTAssertEqual(secondObject?.objectEncoding, 3.0)
    }

    static var allTests = [
        ("testDecodeTrueBoolean", testDecodeTrueBoolean),
        ("testDecodeFalseBoolean", testDecodeFalseBoolean),
        ("testDecodeDouble", testDecodeDouble),
        ("testDecodeString", testDecodeString)
    ]
}
