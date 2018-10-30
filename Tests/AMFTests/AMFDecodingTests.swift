import XCTest
@testable import AMF

class AMFDecodingTests: XCTestCase {
    var decoder: AMFDecoder!
    
    override func setUp() {
        self.decoder = AMFDecoder()
    }
    
    func testDecodeBoolean() {
        let value = try! decoder.decode(Bool.self, from: Data())
        XCTAssertEqual(value, false)
    }

    static var allTests = [
        ("testDecode", testDecode)
    ]
}
