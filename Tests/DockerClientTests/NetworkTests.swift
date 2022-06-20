import XCTest
@testable import DockerClientSwift
import Logging

final class NetworkTests: XCTestCase {
    
    var client: DockerClient!
    
    override func setUp() {
        client = DockerClient.testable()
    }
    
    override func tearDownWithError() throws {
        try client.syncShutdown()
    }
    
    func testNetworkInpsect() async throws {
        let networks = try await client.networks.list()
        let network = try await client.networks.get(networks.first!.id)
        XCTAssert(network.createdAt > Date.distantPast, "ensure createdAt field is parsed")
    }
    
    func testListNetworks() async throws {
        // TODO: improve and check the actual content
        let _ = try await client.networks.list()
    }
    
    func testCreateNetwork() async throws {
        let name = UUID().uuidString
        let network = try await client.networks.create(
            spec: .init(
                name: name,
                ipam: .init(
                    config: [.init(subnet: "192.168.2.0/24", gateway: "192.168.2.1")]
                )
            )
        )
        XCTAssert(network.id != "", "Ensure Network ID is parsed")
        XCTAssert(network.name == name, "Ensure Network name is set")
        XCTAssert(network.ipam.config[0].subnet == "192.168.2.0/24", "Ensure custom subnet is set")
        
        try await client.networks.remove(network.id)
    }
    
    func testPruneNetworks() async throws {
        let name = UUID().uuidString
        let network = try await client.networks.create(
            spec: .init(name: name)
        )
        let pruned = try await client.networks.prune()
        XCTAssert(pruned.contains(network.name), "Ensure created Network has been deleted")
    }
}
