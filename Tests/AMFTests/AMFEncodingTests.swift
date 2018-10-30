import XCTest
@testable import AMF

class AMFEncodingTests: XCTestCase {
    var encoder: AMFEncoder!
    
    override func setUp() {
        self.encoder = AMFEncoder()
    }
 
    func testEncode() {
        let value = try! encoder.encode(false)
        XCTAssertEqual(value, Data())
    }

    static var allTests = [
        ("testEncode", testEncode)
    ]
}
