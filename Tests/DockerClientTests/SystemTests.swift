import XCTest
@testable import DockerClientSwift
import Logging

final class SystemTests: XCTestCase {
    var client: DockerClient!
    
    override func setUp() {
        client = DockerClient.testable()
    }
    
    override func tearDownWithError() throws {
        try! client.syncShutdown()
    }
    
    func testDockerVersion() throws {
        XCTAssertNoThrow(try client.version().wait())
    }
}
