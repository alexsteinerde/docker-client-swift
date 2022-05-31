import XCTest
@testable import DockerClientSwift
import Logging

final class ServiceTests: XCTestCase {
    
    var client: DockerClient!
    
    override func setUp() {
        client = DockerClient.testable()
    }
    
    override func tearDownWithError() throws {
        try! client.syncShutdown()
        // Remove all services in a Docker system `docker service ls -q | xargs echo`
    }
    
    func testListingServices() async throws {
        let name = UUID().uuidString
        let _ = try await client.services.create(serviceName: name, image: Image(id: .init("nginx:alpine")))
        let services = try await client.services.list()
        
        XCTAssert(services.count >= 1)
    }
    
    func testUpdateService() async throws {
        let name = UUID().uuidString
        let service = try await client.services.create(serviceName: name, image: Image(id: .init("nginx:alpine")))
        let updatedService = try await client.services.update(service: service, newImage: Image(id: "nginx:latest"))
        
        XCTAssertTrue(updatedService.version > service.version)
    }
    
    func testInspectService() async throws {
        let name = UUID().uuidString
        let service = try await client.services.create(serviceName: name, image: Image(id: .init("nginx:alpine")))
        XCTAssertNoThrow(Task(priority: .medium) {try await client.services.get(serviceByNameOrId: service.id.value) })
        XCTAssertEqual(service.name, name)
    }
    
    func testCreateService() async throws {
        let name = UUID().uuidString
        let service = try await client.services.create(serviceName: name, image: Image(id: .init("nginx:latest")))
        
        XCTAssertEqual(service.name, name)
    }
    
    func testParsingDate() {
        XCTAssertNotNil(Date.parseDockerDate("2021-03-12T12:34:10.239624085Z"))
    }
}
