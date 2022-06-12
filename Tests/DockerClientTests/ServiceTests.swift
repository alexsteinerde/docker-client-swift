import XCTest
@testable import DockerClientSwift
import Logging

final class ServiceTests: XCTestCase {
    
    var client: DockerClient!
    
    override func setUp() async throws {
        client = DockerClient.testable()
        try? await client.swarm.leave(force: true)
        let _ = try! await client.swarm.initSwarm(config: SwarmConfig())
    }
    
    override func tearDownWithError() throws {
        try client.syncShutdown()
        // Remove all services in a Docker system `docker service ls -q | xargs echo`
    }
    
    func testListingServices() async throws {
        let name = UUID().uuidString
        let _ = try await client.services.create(serviceName: name, image: Image(id: .init("nginx:alpine")))
        let services = try await client.services.list()
        print("\n•••• testListingServices(): \(services)")
        XCTAssert(services.count >= 1)
    }
    
    /*func testUpdateService() async throws {
        let name = UUID().uuidString
        let service = try await client.services.create(serviceName: name, image: Image(id: .init("nginx:alpine")))
        let updatedService = try await client.services.update(service: service, newImage: Image(id: "nginx:latest"))
        
        XCTAssertTrue(updatedService.version > service.version)
    }*/
    
    func testInspectService() async throws {
        let name = UUID().uuidString
        let service = try await client.services.create(serviceName: name, image: Image(id: .init("nginx:alpine")))
        try await Task.sleep(nanoseconds: 3_000_000_000)
        XCTAssertNoThrow(Task(priority: .medium) {try await client.services.get(service.id) })
        XCTAssertEqual(service.spec.name, name)
    }
    
    func testCreateServiceSimple() async throws {
        let name = UUID().uuidString
        let service = try await client.services.create(serviceName: name, image: Image(id: .init("nginx:latest")))
        
        XCTAssertEqual(service.spec.name, name)
    }
    
    func testCreateServiceAdvanced() async throws {
        let name = UUID().uuidString
        let spec = ServiceSpec(
            name: name,
            taskTemplate: .init(
                containerSpec: .init(image: "nginx:latest")
            ),
            mode: .init(
                replicated: .init(replicas: 1)
            )
        )
        let id = try await client.services.create(spec: spec)
        let service = try await client.services.get(id)
        
        XCTAssertEqual(service.spec.name, name)
    }
    
    func testGetServiceLogs() async throws {
        try await client.images.pullImage(byName: "nginx", tag: "latest")
        let name = UUID().uuidString
        let service = try await client.services.create(serviceName: name, image: Image(id: .init("nginx:latest")))
        // wait until service is running and Nginx has produced logs
        // not sure how to improve that, might lead to flaky test
        try await Task.sleep(nanoseconds: 5_000_000_000)
        for try await line in try await client.services.logs(service: service, timestamps: true) {
            XCTAssert(line.timestamp != Date.distantPast, "Ensure timestamp is parsed properly")
            //XCTAssert(line.source == .stdout, "Ensure stdout is properly detected")
        }
    }
    
    func textZzzLeaveSwarm() async throws {
        try await client.swarm.leave()
    }
}
