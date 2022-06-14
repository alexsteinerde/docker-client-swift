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
    
    /*func testConfigInpsect() async throws {
        let configs = try await client.configs.list()
        let config = try await client.networks.get(configs.first!.id)
        XCTAssert(config.createdAt > Date.distantPast, "ensure createdAt field is parsed")
    }*/
    
    func testListConfigs() async throws {
        // TODO: improve and check the actual content
        let _ = try await client.configs.list()
    }
    
    func testCreateConfig() async throws {
        let name = UUID().uuidString
        let config = try await client.configs.create(
            spec: .init(
                name: name,
                data: "test config value".data(using: .utf8)!.base64EncodedString()
            )
        )
        XCTAssert(config.id != "", "Ensure ID is parsed")
        XCTAssert(config.spec.name == name, "Ensure name is set")
        
        try await client.configs.remove(config.id)
    }
}
