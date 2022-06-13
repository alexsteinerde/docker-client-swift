import XCTest
@testable import DockerClientSwift
import Logging

final class VolumeTests: XCTestCase {
    
    var client: DockerClient!
    
    override func setUp() {
        client = DockerClient.testable()
    }
    
    override func tearDownWithError() throws {
        try client.syncShutdown()
    }
    
    func testListVolumes() async throws {
        // TODO: improve and check the actual content
        let _ = try await client.volumes.list()
    }
}
