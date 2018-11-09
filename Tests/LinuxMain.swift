import XCTest
@testable import AMFTests

XCTMain([
    testCase(AMF0DecodingTests.allTests),
    testCase(AMF0EncodingTests.allTests),
    testCase(AMF0PerformanceTests.allTests),
    testCase(AMF0RoundTripTests.allTests),
    testCase(AMF3DecodingTests.allTests),
    testCase(AMF3EncodingTests.allTests),
    testCase(AMF3PerformanceTests.allTests),
    testCase(AMF3RoundTripTests.allTests),
])
