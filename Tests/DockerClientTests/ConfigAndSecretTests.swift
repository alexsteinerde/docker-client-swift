import XCTest
@testable import DockerClientSwift
import Logging

final class ConfigAndSecretTests: XCTestCase {
    
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
        let configData = "test config value 💥".data(using: .utf8)!
        let config = try await client.configs.create(
            spec: .init(
                name: name,
                data: configData
            )
        )
        XCTAssert(config.id != "", "Ensure ID is parsed")
        XCTAssert(config.spec.name == name, "Ensure name is set")
        XCTAssert(config.spec.data == configData, "Ensure data is correct")
        try await client.configs.remove(config.id)
    }
    
    func testCreateSecret() async throws {
        let name = UUID().uuidString
        let secretData = "test secret value".data(using: .utf8)!
        let secret = try await client.secrets.create(
            spec: .init(
                name: name,
                data: secretData
            )
        )
        XCTAssert(secret.id != "", "Ensure ID is parsed")
        XCTAssert(secret.spec.name == name, "Ensure name is set")
        try await client.secrets.remove(secret.id)
    }
}
