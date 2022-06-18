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
    
    func testCreateDeleteVolume() async throws {
        let name = UUID().uuidString
        let volume = try await client.volumes.create(
            spec: .init(name: name, labels: ["myLabel": "value"])
        )
        XCTAssert(volume.name == name, "Ensure volume name is set")
        try await client.volumes.remove(name, force: true)
    }
    
    func testListVolumes() async throws {
        // TODO: improve and check the actual content
        let _ = try await client.volumes.list()
    }
    
    func testPruneVolumes() async throws {
        let name = UUID().uuidString
        let volume = try await client.volumes.create(
            spec: .init(name: name)
        )
        let pruned = try await client.volumes.prune()
        XCTAssert(pruned.volumesDeleted.contains(volume.name), "Ensure created Volume got deleted")
    }
}
