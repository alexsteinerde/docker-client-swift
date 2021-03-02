import XCTest
@testable import DockerClientSwift
import Logging

final class ImageTests: XCTestCase {
    func testListImage() throws {
        let client = DockerClient.testable()
        let _ = try client.images.pullImage(byName: "hello-world", tag: "latest").wait()
        
        let images = try client.images.list().wait()
        
        XCTAssert(images.count >= 1)
    }
}
