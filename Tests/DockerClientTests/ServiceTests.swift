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
    }
    
    func testListingServices() throws {
        let name = UUID().uuidString
        let _ = try client.services.create(serviceName: name, image: Image(id: .init("nginx:alpine"))).wait()
        let services = try client.services.list().wait()
        
        XCTAssert(services.count >= 1)
    }
    
    func testUpdateService() throws {
        let name = UUID().uuidString
        let service = try client.services.create(serviceName: name, image: Image(id: .init("nginx:alpine"))).wait()
        let updatedService = try client.services.update(service: service, newImage: Image(id: "nginx:latest")).wait()
        
        XCTAssertTrue(updatedService.version > service.version)
    }
    
    func testInspectService() throws {
        let name = UUID().uuidString
        let service = try client.services.create(serviceName: name, image: Image(id: .init("nginx:alpine"))).wait()
        XCTAssertNoThrow(try client.services.get(serviceByNameOrId: service.id.value))
        XCTAssertEqual(service.name, name)
    }
    
    func testCreateService() throws {
        let name = UUID().uuidString
        let service = try client.services.create(serviceName: name, image: Image(id: .init("nginx:latest"))).wait()
        
        XCTAssertEqual(service.name, name)
    }
    
    func testParsingDate() {
        XCTAssertNotNil(Date.parseDockerDate("2021-03-12T12:34:10.239624085Z"))
    }
}
