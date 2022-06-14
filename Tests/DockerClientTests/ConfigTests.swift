import XCTest
@testable import DockerClientSwift
import Logging

final class ConfigTests: XCTestCase {
    
    var client: DockerClient!
    
    override func setUp() async throws {
        client = DockerClient.testable()
        try? await client.swarm.leave(force: true)
        let _ = try! await client.swarm.initSwarm(config: SwarmConfig())
    }
    
    override func tearDownWithError() throws {
        try client.syncShutdown()
    }
    
    func testListConfigs() async throws {
        // TODO: improve and check the actual content
        let _ = try await client.configs.list()
    }
    
    func testCreateConfig() async throws {
        let name = UUID().uuidString
        let b64Data = "test config value".data(using: .utf8)!.base64EncodedString()
        let config = try await client.configs.create(
            spec: .init(
                name: name,
                data: b64Data
            )
        )
        XCTAssert(config.id != "", "Ensure ID is parsed")
        XCTAssert(config.spec.name == name, "Ensure name is set")
        XCTAssert(config.spec.data == b64Data, "Ensure data is correct")
        try await client.configs.remove(config.id)
    }
}
