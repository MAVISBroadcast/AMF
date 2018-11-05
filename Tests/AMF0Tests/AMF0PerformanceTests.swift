@testable import AMF
import XCTest

class AMF0PerformanceTests: XCTestCase {
    var encoder: AMF0Encoder!
    var decoder: AMF0Decoder!

    override func setUp() {
        encoder = AMF0Encoder()
        decoder = AMF0Decoder()
    }

    func testDecodingPerformance() {
        // This is an example of a performance test case.
        // The below is AMF0 lifted from https://en.wikipedia.org/wiki/Action_Message_Format it is the AMF0 portion of an RTMP message
        let data = Data(bytes: [0x02, 0x00, 0x07, 0x5F, 0x72, 0x65, 0x73, 0x75, 0x6C, 0x74, 0x00, 0x3F, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x06, 0x66, 0x6D, 0x73, 0x56, 0x65, 0x72, 0x02, 0x00, 0x0E, 0x46, 0x4D, 0x53, 0x2F, 0x33, 0x2C, 0x35, 0x2C, 0x35, 0x2C, 0x32, 0x30, 0x30, 0x34, 0x00, 0x0C, 0x63, 0x61, 0x70, 0x61, 0x62, 0x69, 0x6C, 0x69, 0x74, 0x69, 0x65, 0x73, 0x00, 0x40, 0x3F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x6D, 0x6F, 0x64, 0x65, 0x00, 0x3F, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x03, 0x00, 0x05, 0x6C, 0x65, 0x76, 0x65, 0x6C, 0x02, 0x00, 0x06, 0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x00, 0x04, 0x63, 0x6F, 0x64, 0x65, 0x02, 0x00, 0x1D, 0x4E, 0x65, 0x74, 0x43, 0x6F, 0x6E, 0x6E, 0x65, 0x63, 0x74, 0x69, 0x6F, 0x6E, 0x2E, 0x43, 0x6F, 0x6E, 0x6E, 0x65, 0x63, 0x74, 0x2E, 0x53, 0x75, 0x63, 0x63, 0x65, 0x73, 0x73, 0x00, 0x0B, 0x64, 0x65, 0x73, 0x63, 0x72, 0x69, 0x70, 0x74, 0x69, 0x6F, 0x6E, 0x02, 0x00, 0x15, 0x43, 0x6F, 0x6E, 0x6E, 0x65, 0x63, 0x74, 0x69, 0x6F, 0x6E, 0x20, 0x73, 0x75, 0x63, 0x63, 0x65, 0x65, 0x64, 0x65, 0x64, 0x2E, 0x00, 0x04, 0x64, 0x61, 0x74, 0x61, 0x08, 0x00, 0x00, 0x00, 0x01, 0x00, 0x07, 0x76, 0x65, 0x72, 0x73, 0x69, 0x6F, 0x6E, 0x02, 0x00, 0x0A, 0x33, 0x2C, 0x35, 0x2C, 0x35, 0x2C, 0x32, 0x30, 0x30, 0x34, 0x00, 0x00, 0x09, 0x00, 0x08, 0x63, 0x6C, 0x69, 0x65, 0x6E, 0x74, 0x49, 0x64, 0x00, 0x41, 0xD7, 0x9B, 0x78, 0x7C, 0xC0, 0x00, 0x00, 0x00, 0x0E, 0x6F, 0x62, 0x6A, 0x65, 0x63, 0x74, 0x45, 0x6E, 0x63, 0x6F, 0x64, 0x69, 0x6E, 0x67, 0x00, 0x40, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09])

        self.measure {
            for _ in 0..<1_000 {
                _ = try? decoder.decode(String.self, from: data)
                _ = try? decoder.decode(Double.self, from: data[decoder.finishedIndex...])
                _ = try? decoder.decode(AMFProperties.self, from: data[decoder.finishedIndex...])
                _ = try? decoder.decode(AMFInformation.self, from: data[decoder.finishedIndex...])
            }
        }
    }

    func testEncodingPerformance() {
        // The below is AMF0 lifted from https://en.wikipedia.org/wiki/Action_Message_Format it is the AMF0 portion of an RTMP message
        let data = Data(bytes: [0x02, 0x00, 0x07, 0x5F, 0x72, 0x65, 0x73, 0x75, 0x6C, 0x74, 0x00, 0x3F, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x06, 0x66, 0x6D, 0x73, 0x56, 0x65, 0x72, 0x02, 0x00, 0x0E, 0x46, 0x4D, 0x53, 0x2F, 0x33, 0x2C, 0x35, 0x2C, 0x35, 0x2C, 0x32, 0x30, 0x30, 0x34, 0x00, 0x0C, 0x63, 0x61, 0x70, 0x61, 0x62, 0x69, 0x6C, 0x69, 0x74, 0x69, 0x65, 0x73, 0x00, 0x40, 0x3F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x6D, 0x6F, 0x64, 0x65, 0x00, 0x3F, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x03, 0x00, 0x05, 0x6C, 0x65, 0x76, 0x65, 0x6C, 0x02, 0x00, 0x06, 0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x00, 0x04, 0x63, 0x6F, 0x64, 0x65, 0x02, 0x00, 0x1D, 0x4E, 0x65, 0x74, 0x43, 0x6F, 0x6E, 0x6E, 0x65, 0x63, 0x74, 0x69, 0x6F, 0x6E, 0x2E, 0x43, 0x6F, 0x6E, 0x6E, 0x65, 0x63, 0x74, 0x2E, 0x53, 0x75, 0x63, 0x63, 0x65, 0x73, 0x73, 0x00, 0x0B, 0x64, 0x65, 0x73, 0x63, 0x72, 0x69, 0x70, 0x74, 0x69, 0x6F, 0x6E, 0x02, 0x00, 0x15, 0x43, 0x6F, 0x6E, 0x6E, 0x65, 0x63, 0x74, 0x69, 0x6F, 0x6E, 0x20, 0x73, 0x75, 0x63, 0x63, 0x65, 0x65, 0x64, 0x65, 0x64, 0x2E, 0x00, 0x04, 0x64, 0x61, 0x74, 0x61, 0x08, 0x00, 0x00, 0x00, 0x01, 0x00, 0x07, 0x76, 0x65, 0x72, 0x73, 0x69, 0x6F, 0x6E, 0x02, 0x00, 0x0A, 0x33, 0x2C, 0x35, 0x2C, 0x35, 0x2C, 0x32, 0x30, 0x30, 0x34, 0x00, 0x00, 0x09, 0x00, 0x08, 0x63, 0x6C, 0x69, 0x65, 0x6E, 0x74, 0x49, 0x64, 0x00, 0x41, 0xD7, 0x9B, 0x78, 0x7C, 0xC0, 0x00, 0x00, 0x00, 0x0E, 0x6F, 0x62, 0x6A, 0x65, 0x63, 0x74, 0x45, 0x6E, 0x63, 0x6F, 0x64, 0x69, 0x6E, 0x67, 0x00, 0x40, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09])
        let value = try? decoder.decode(String.self, from: data)
        XCTAssertEqual(value, "_result")
        let transactionID = try? decoder.decode(Double.self, from: data[decoder.finishedIndex...])
        XCTAssertEqual(transactionID, 1)
        let firstObject = try? decoder.decode(AMFProperties.self, from: data[decoder.finishedIndex...])
        XCTAssertEqual(firstObject?.fmsVer, "FMS/3,5,5,2004")
        XCTAssertEqual(firstObject?.capabilities, 31.0)
        XCTAssertEqual(firstObject?.mode, 1.0)
        let secondObject = try? decoder.decode(AMFInformation.self, from: data[decoder.finishedIndex...])
        XCTAssertEqual(secondObject?.clientId, 1_584_259_571)
        XCTAssertEqual(secondObject?.code, "NetConnection.Connect.Success")
        XCTAssertEqual(secondObject?.level, "status")
        XCTAssertEqual(secondObject?.objectEncoding, 3.0)
        XCTAssertEqual(secondObject?.description, "Connection succeeded.")
        XCTAssertEqual(secondObject?.data["version"], "3,5,5,2004")

        var constructedData = Data()
        self.measure {
            for _ in 0..<1_000 {
                constructedData.append(try! encoder.encode(value))
                constructedData.append(try! encoder.encode(transactionID))
                constructedData.append(try! encoder.encode(firstObject))
                constructedData.append(try! encoder.encode(secondObject))
            }
        }
    }

    static var allTests = [
        ("testDecodingPerformance", testDecodingPerformance),
        ("testEncodingPerformance", testEncodingPerformance),
        ]
}
