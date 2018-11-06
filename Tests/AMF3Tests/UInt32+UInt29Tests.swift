@testable import AMF
import XCTest

class UInt32_UInt29FromDataTests: XCTestCase {
    func testOneByteInt() {
        let data = Data([0b0111_1111])
        let uInt32 = UInt32(variableBytes: data)
        XCTAssertEqual(uInt32, 0x7F)
    }

    func testTwoByteJustOverflowedInt() {
        let data = Data([0b1000_0001, 0b0_0000_0000])
        let uInt32 = UInt32(variableBytes: data)
        XCTAssertEqual(uInt32, 0x80)
    }

    func testTwoBytesFullSignificantByteInt() {
        let data = Data([0b1111_1111, 0b0111_1111])
        let uInt32 = UInt32(variableBytes: data)
        XCTAssertEqual(uInt32, 0x3FFF)
    }

    func testThreeBytesJustOverflowedInt() {
        let data = Data([0b1000_0001, 0b1000_0000, 0b0000_0000])
        let uInt32 = UInt32(variableBytes: data)
        XCTAssertEqual(uInt32, 0x4000)
    }

    func testThreeBytesFullInt() {
        let data = Data([0b1111_1111, 0b1111_1111, 0b0111_1111])
        let uInt32 = UInt32(variableBytes: data)
        XCTAssertEqual(uInt32, 0x1FFFFF)
    }

    func testFourBytesJustOverflowedInt() {
        let data = Data([0b1000_0000, 0b1100_0000, 0b1000_0000, 0b0000_0000])
        let uInt32 = UInt32(variableBytes: data)
        XCTAssertEqual(uInt32, 0x0020_0000)
    }

    func testFourBytesJustOverflowedIntoMostSignificantByteInt() {
        let data = Data([0b1000_0001, 0b1000_0000, 0b1000_0000, 0b0000_0000])
        let uInt32 = UInt32(variableBytes: data)
        XCTAssertEqual(uInt32, 0x0040_0000)
    }

    func testFourBytesFullInt() {
        let data = Data([0b1111_1111, 0b1111_1111, 0b1111_1111, 0b1111_1111])
        let uInt32 = UInt32(variableBytes: data)
        XCTAssertEqual(uInt32, 0x1FFF_FFFF) // 2^29 - 1
    }
}

class UInt32_UInt29ToDataTests: XCTestCase {
    func testOneByteInt() {
        let bytes: [UInt8] = [0b0111_1111]
        let uInt32 = UInt32(0x7F)
        XCTAssertEqual(try? uInt32.variableBytes(), bytes)
    }

    func testTwoByteJustOverflowedInt() {
        let bytes: [UInt8] = [0b1000_0001, 0b0_0000_0000]
        let uInt32 = UInt32(0x80)
        XCTAssertEqual(try? uInt32.variableBytes(), bytes)
    }

    func testTwoBytesFullSignificantByteInt() {
        let bytes: [UInt8] = [0b1111_1111, 0b0111_1111]
        let uInt32 = UInt32(0x3FFF)
        XCTAssertEqual(try? uInt32.variableBytes(), bytes)
    }

    func testThreeBytesJustOverflowedInt() {
        let bytes: [UInt8] = [0b1000_0001, 0b1000_0000, 0b0000_0000]
        let uInt32 = UInt32(0x4000)
        XCTAssertEqual(try? uInt32.variableBytes(), bytes)
    }

    func testThreeBytesFullInt() {
        let bytes: [UInt8] = [0b1111_1111, 0b1111_1111, 0b0111_1111]
        let uInt32 = UInt32(0x1FFFFF)
        XCTAssertEqual(try? uInt32.variableBytes(), bytes)
    }

    func testFourBytesJustOverflowedInt() {
        let bytes: [UInt8] = [0b1000_0000, 0b1100_0000, 0b1000_0000, 0b0000_0000]
        let uInt32 = UInt32(0x0020_0000)
        XCTAssertEqual(try? uInt32.variableBytes(), bytes)
    }

    func testFourBytesJustOverflowedIntoMostSignificantByteInt() {
        let bytes: [UInt8] = [0b1000_0001, 0b1000_0000, 0b1000_0000, 0b0000_0000]
        let uInt32 = UInt32(0x0040_0000)
        XCTAssertEqual(try? uInt32.variableBytes(), bytes)
    }

    func testFourBytesFullInt() {
        let bytes: [UInt8] = [0b1111_1111, 0b1111_1111, 0b1111_1111, 0b1111_1111]
        let uInt32 = UInt32(0x1FFF_FFFF)
        XCTAssertEqual(try? uInt32.variableBytes(), bytes) // 2^29 - 1
    }
}
