import XCTest
@testable import AMF

class AMFDecodingTests: XCTestCase {
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
        let stringData = Data(bytes: [AMF0Marker.string.rawValue, /* big endian length of 5*/ 0x00, 0x05, /* UTF8 chars */ 0x68, 0x65, 0x6C, 0x6C, 0x6F])
        let value = try! decoder.decode(String.self, from: stringData)
        XCTAssertEqual(value, "hello")
    }

    func testDecodeEmoji() {
        let stringData = Data(bytes: [AMF0Marker.string.rawValue, /* big endian length of 20*/ 0x00, 0x14, /* dank emojis  😀😃😄😁😆*/ 0xF0, 0x9F, 0x98, 0x80, 0xF0, 0x9F, 0x98, 0x83, 0xF0, 0x9F, 0x98, 0x84, 0xF0, 0x9F, 0x98, 0x81, 0xF0, 0x9F, 0x98, 0x86])
        let value = try! decoder.decode(String.self, from: stringData)
        XCTAssertEqual(value, "😀😃😄😁😆")
    }

    static var allTests = [
        ("testDecodeTrueBoolean", testDecodeTrueBoolean),
        ("testDecodeFalseBoolean", testDecodeFalseBoolean),
        ("testDecodeDouble", testDecodeDouble),
        ("testDecodeString", testDecodeString)
    ]
}
