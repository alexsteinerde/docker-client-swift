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
    }
    
    func testListNetworks() async throws {
        // TODO: improve and check the actual content
        let _ = try await client.networks.list()
    }
}
