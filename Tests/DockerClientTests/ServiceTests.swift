import XCTest
@testable import DockerClientSwift
import Logging

final class ServiceTests: XCTestCase {
    
    var client: DockerClient!
    
    override func setUp() async throws {
        client = DockerClient.testable()
        async let image = try client.images.pull(byName: "nginx", tag: "latest")
        try? await client.swarm.leave(force: true)
        let _ = try! await client.swarm.initSwarm(config: SwarmConfig())
        let _ = try await image
    }
    
    override func tearDownWithError() throws {
        try client.syncShutdown()
        // Remove all services in a Docker system `docker service ls -q | xargs echo`
    }
    
    func testListingServices() async throws {
        let name = UUID().uuidString
        let spec = ServiceSpec(
            name: name,
            taskTemplate: .init(
                containerSpec: .init(image: "nginx:latest"),
                resources: .init(
                    limits: .init(memoryBytes: UInt64(64 * 1024 * 1024))
                )
            ),
            mode: .init(
                replicated: .init(replicas: 1)
            )
        )
        let _ = try await client.services.create(spec: spec)
        
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
        let spec = ServiceSpec(
            name: name,
            taskTemplate: .init(
                containerSpec: .init(image: "nginx:latest"),
                resources: .init(
                    limits: .init(memoryBytes: UInt64(64 * 1024 * 1024))
                )
            ),
            mode: .init(
                replicated: .init(replicas: 1)
            )
        )
        let service = try await client.services.create(spec: spec)
        try await Task.sleep(nanoseconds: 3_000_000_000)
        XCTAssertEqual(service.spec.name, name)
    }
    
    /*func testCreateServiceSimple() async throws {
        let name = UUID().uuidString
        let service = try await client.services.create(serviceName: name, image: Image(id: .init("nginx:latest")))
        
        XCTAssertEqual(service.spec.name, name)
    }*/
    
    func testCreateServiceAdvanced() async throws {
        let name = UUID().uuidString
        let spec = ServiceSpec(
            name: name,
            taskTemplate: .init(
                containerSpec: .init(image: "nginx:latest"),
                resources: .init(
                    limits: .init(memoryBytes: UInt64(64 * 1024 * 1024))
                )
            ),
            mode: .init(
                replicated: .init(replicas: 1)
            )
        )
        let service = try await client.services.create(spec: spec)
        
        XCTAssert(service.spec.name == name, "Ensure custom service name is set")
        XCTAssert(service.spec.taskTemplate.resources?.limits?.memoryBytes == 64 * 1024 * 1024, "Ensure memory limit is set")
    }
    
    func testGetServiceLogs() async throws {
        let name = UUID().uuidString
        let spec = ServiceSpec(
            name: name,
            taskTemplate: .init(
                containerSpec: .init(image: "nginx:latest", tty: false)
            ),
            mode: .init(
                replicated: .init(replicas: 1)
            )
        )
        let service = try await client.services.create(spec: spec)
        
        // wait until service is running and Nginx has produced logs
        // not sure how to improve that, might lead to flaky test
        try await Task.sleep(nanoseconds: 5_000_000_000)
        // TODO: test with tty = false and timestamps = true once bug fixed
        for try await line in try await client.services.logs(service: service, timestamps: true) {
            XCTAssert(line.timestamp != Date.distantPast, "Ensure timestamp is parsed properly")
            //XCTAssert(line.source == .stdout, "Ensure stdout is properly detected")
        }
    }
    
    func textZzzLeaveSwarm() async throws {
        try await client.swarm.leave()
    }
}
