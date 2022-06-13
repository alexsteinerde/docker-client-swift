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
            spec: .init(name: name)
        )
        XCTAssert(network.id != "", "Ensure Network ID is parsed")
        XCTAssert(network.name == name, "Ensure Network name is set")
        
        try await client.networks.remove(network.id)
    }
}
