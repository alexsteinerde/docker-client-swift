import XCTest
@testable import DockerClientSwift
import Logging

final class SystemTests: XCTestCase {
    func testDockerVersion() throws {
        let client = DockerClient.testable()

        XCTAssertNoThrow(try client.version().wait())
    }
}
