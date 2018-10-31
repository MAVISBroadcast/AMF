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

    static var allTests = [
        ("testDecodeTrueBoolean", testDecodeTrueBoolean),
        ("testDecodeFalseBoolean", testDecodeFalseBoolean),
        ("testDecodeDouble", testDecodeDouble),
        ("testDecodeString", testDecodeString)
    ]
}
