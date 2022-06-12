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
    
    func testDataUsage() async throws {
        let _ = try await client.images.pullImage(byName: "hello-world", tag: "latest")
        let dataUsage = try await client.dataUsage()
        XCTAssert(dataUsage.layersSize > 0, "Ensure layersSize is parsed")
        XCTAssert(dataUsage.images.count > 0, "Ensure images field is parsed")
    }
    
    func testEvents() async throws {
        let name = UUID().uuidString
        async let events = try await client.events()
        let container = try await client.containers.create(
            name: name,
            spec: .init(
                config: .init(image: "hello-world:latest"),
                hostConfig: .init()
            )
        )
        for try await event in try await events {
            if event.action == .create && event.type == .container {
                XCTAssert(event.actor.attributes?["name"] == name, "Ensure create event for this container is emitted")
                break
            }
        }
        try await client.containers.remove(name, force: true, removeAnonymousVolumes: true)
    }
    
    func testSystemInfo() async throws {
        let info = try await client.info()
        XCTAssert(info.id != "", "Ensure id is set")
    }
    
    func testPing() async throws {
        try await client.ping()
    }
    
    func testSystemInfoWithSwarm() async throws {
        try? await client.swarm.leave(force: true)
        let _ = try! await client.swarm.initSwarm(config: SwarmConfig())
        let info = try await client.info()
        try? await client.swarm.leave(force: true)
        //print("\n••••••••• DOCKER system info=\(info)")
    }
}
