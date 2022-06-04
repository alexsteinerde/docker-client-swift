import XCTest
@testable import DockerClientSwift
import Logging

final class SwarmTests: XCTestCase {
    
    var client: DockerClient!
    
    override func setUp() async throws {
        client = DockerClient.testable()
    }
    
    override func tearDownWithError() throws {
        try client.syncShutdown()
    }
    
    func testInit() async throws {
        // Ensure Docker is not in Swarm mode
        try? await client.swarm.leave(force: true)
        
        let config = SwarmCreate(Spec: .init(Labels: ["test.label": "value"]))
        let id = try await client.swarm.initSwarm(config: config)
        XCTAssertTrue(id != "" , "Ensure Swarm ID is returned")
        
        let swarm = try await client.swarm.get()
        XCTAssertTrue(swarm.Spec.Labels!["test.label"] == "value", "Ensure Swarm Labels are set")
    }
    
    func testInspect() async throws {
        let swarm = try await client.swarm.get()
        //print("\n•••• Swarm=\(swarm)")
        XCTAssertTrue(swarm.ID.count == "4evkkpryustfhlcmkxl5oepns".count)
        XCTAssertTrue(swarm.Spec.Name == "default", "Ensure Swarm Name is returned")
    }
    
    func testUpdate() async throws {
        let swarm = try await client.swarm.get()
        try await client.swarm.update(spec: swarm.Spec, version: swarm.Version.Index)
    }
    
    func testZLeave() async throws {
        try await client.swarm.leave(force: true)
    }
}
