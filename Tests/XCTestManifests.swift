import XCTest

extension AMF0DecodingTests {
    static let __allTests = [
        ("testAMFObject", testAMFObject),
        ("testArray", testArray),
        ("testBiggerDictionary", testBiggerDictionary),
        ("testDate", testDate),
        ("testDecodeDouble", testDecodeDouble),
        ("testDecodeEmoji", testDecodeEmoji),
        ("testDecodeEmptyString", testDecodeEmptyString),
        ("testDecodeFalseBoolean", testDecodeFalseBoolean),
        ("testDecodeNil", testDecodeNil),
        ("testDecodeString", testDecodeString),
        ("testDecodeTrueBoolean", testDecodeTrueBoolean),
        ("testDictionary", testDictionary),
        ("testDictionaryWithArrayInIt", testDictionaryWithArrayInIt),
        ("testECMAArray", testECMAArray),
        ("testEmptyArray", testEmptyArray),
        ("testLargerAMFObject", testLargerAMFObject),
        ("testLongString", testLongString),
        ("testNamedObject", testNamedObject),
        ("testReference", testReference),
    ]
}

extension AMF0EncodingTests {
    static let __allTests = [
        ("testBoolEncode", testBoolEncode),
        ("testDateEncode", testDateEncode),
        ("testDateObjectEncode", testDateObjectEncode),
        ("testDoubleEncode", testDoubleEncode),
        ("testEmptyStringEncode", testEmptyStringEncode),
        ("testEncodeArray", testEncodeArray),
        ("testEncodeECMAArray", testEncodeECMAArray),
        ("testEncodeECMAArrayDouble", testEncodeECMAArrayDouble),
        ("testEncodeNil", testEncodeNil),
        ("testStringEncode", testStringEncode),
    ]
}

extension AMF0PerformanceTests {
    static let __allTests = [
        ("testDecodingPerformance", testDecodingPerformance),
        ("testEncodingPerformance", testEncodingPerformance),
    ]
}

extension AMF0RoundTripTests {
    static let __allTests = [
        ("testLargerAMFObject", testLargerAMFObject),
        ("testRoundTrip", testRoundTrip),
    ]
}

extension AMF3DecodingTests {
    static let __allTests = [
        ("testArray", testArray),
        ("testBiggerDictionary", testBiggerDictionary),
        ("testDate", testDate),
        ("testDecodeDouble", testDecodeDouble),
        ("testDecodeEmoji", testDecodeEmoji),
        ("testDecodeEmptyString", testDecodeEmptyString),
        ("testDecodeFalseBoolean", testDecodeFalseBoolean),
        ("testDecodeNil", testDecodeNil),
        ("testDecodeString", testDecodeString),
        ("testDecodeTrueBoolean", testDecodeTrueBoolean),
        ("testDictionary", testDictionary),
        ("testDictionaryWithArrayInIt", testDictionaryWithArrayInIt),
        ("testEmptyArray", testEmptyArray),
    ]
}

extension AMF3EncodingTests {
    static let __allTests = [
        ("testBoolEncode", testBoolEncode),
        ("testDateEncode", testDateEncode),
        ("testDictionary", testDictionary),
        ("testDoubleEncode", testDoubleEncode),
        ("testEmptyStringEncode", testEmptyStringEncode),
        ("testEncodeArray", testEncodeArray),
        ("testEncodeNil", testEncodeNil),
        ("testStringEncode", testStringEncode),
    ]
}

extension AMF3PerformanceTests {
    static let __allTests = [
        ("testRoundtripPerformance", testRoundtripPerformance),
    ]
}

extension AMF3RoundTripTests {
    static let __allTests = [
        ("testRoundTrip", testRoundTrip),
    ]
}

extension UInt32_UInt29FromDataTests {
    static let __allTests = [
        ("testFourBytesFullInt", testFourBytesFullInt),
        ("testFourBytesJustOverflowedInt", testFourBytesJustOverflowedInt),
        ("testFourBytesJustOverflowedIntoMostSignificantByteInt", testFourBytesJustOverflowedIntoMostSignificantByteInt),
        ("testOneByteInt", testOneByteInt),
        ("testThreeBytesFullInt", testThreeBytesFullInt),
        ("testThreeBytesJustOverflowedInt", testThreeBytesJustOverflowedInt),
        ("testTwoByteJustOverflowedInt", testTwoByteJustOverflowedInt),
        ("testTwoBytesFullSignificantByteInt", testTwoBytesFullSignificantByteInt),
    ]
}

extension UInt32_UInt29ToDataTests {
    static let __allTests = [
        ("testFourBytesFullInt", testFourBytesFullInt),
        ("testFourBytesJustOverflowedInt", testFourBytesJustOverflowedInt),
        ("testFourBytesJustOverflowedIntoMostSignificantByteInt", testFourBytesJustOverflowedIntoMostSignificantByteInt),
        ("testOneByteInt", testOneByteInt),
        ("testThreeBytesFullInt", testThreeBytesFullInt),
        ("testThreeBytesJustOverflowedInt", testThreeBytesJustOverflowedInt),
        ("testTwoByteJustOverflowedInt", testTwoByteJustOverflowedInt),
        ("testTwoBytesFullSignificantByteInt", testTwoBytesFullSignificantByteInt),
    ]
}

#if !os(macOS)
    public func __allTests() -> [XCTestCaseEntry] {
        return [
            testCase(AMF0DecodingTests.__allTests),
            testCase(AMF0EncodingTests.__allTests),
            testCase(AMF0PerformanceTests.__allTests),
            testCase(AMF0RoundTripTests.__allTests),
            testCase(AMF3DecodingTests.__allTests),
            testCase(AMF3EncodingTests.__allTests),
            testCase(AMF3PerformanceTests.__allTests),
            testCase(AMF3RoundTripTests.__allTests),
            testCase(UInt32_UInt29FromDataTests.__allTests),
            testCase(UInt32_UInt29ToDataTests.__allTests),
        ]
    }
#endif
