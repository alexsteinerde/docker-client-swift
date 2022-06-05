import XCTest
@testable import DockerClientSwift
import Logging

final class SystemTests: XCTestCase {
    var client: DockerClient!
    
    override func setUp() {
        client = DockerClient.testable()
    }
    
    override func tearDownWithError() throws {
        try client.syncShutdown()
    }
    
    func testDockerVersion() async throws {
        let version = try await client.version()
        XCTAssert(version.version != "", "Ensure Version field is set")
    }
    
    func testSystemInfo() async throws {
        let info = try await client.info()
        XCTAssert(info.id != "", "Ensure id is set")
    }
    
    func testSystemInfoWithSwarm() async throws {
        try? await client.swarm.leave(force: true)
        let _ = try! await client.swarm.initSwarm(config: SwarmConfig())
        let info = try await client.info()
        try? await client.swarm.leave(force: true)
        print("\n••••••••• DOCKER system info=\(info)")
    }
}
