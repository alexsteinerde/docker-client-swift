import XCTest
@testable import DockerClientSwift
import Logging

final class NodeTests: XCTestCase {
    
    var client: DockerClient!
    
    override func setUp() async throws {
        client = DockerClient.testable()
    }
    
    override func tearDownWithError() throws {
        try client.syncShutdown()
    }
    
    func testList() async throws {
        // Ensure Docker is not in Swarm mode
        try? await client.swarm.leave(force: true)
        
        let _ = try await client.swarm.initSwarm(config: SwarmConfig())
        let nodes = try await client.nodes.list()
        print("•••• NODES=\(nodes)")
        try? await client.swarm.leave(force: true)
    }
}
