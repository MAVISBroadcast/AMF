import XCTest
@testable import AMF

class AMFEncodingTests: XCTestCase {
    var encoder: AMF0Encoder!
    
    override func setUp() {
        self.encoder = AMF0Encoder()
    }
 
//    func testEncode() {
//        let value = try! encoder.encode(false)
//        XCTAssertEqual(value, Data())
//    }
//
//    static var allTests = [
//        ("testEncode", testEncode)
//    ]
}
