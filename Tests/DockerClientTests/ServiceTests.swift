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
        let replicas = 1
        let spec = ServiceSpec(
            name: name,
            taskTemplate: .init(
                containerSpec: .init(image: "nginx:latest", tty: false)
            ),
            mode: .init(
                replicated: .init(replicas: UInt32(replicas))
            )
        )
        let service = try await client.services.create(spec: spec)
        
        
        var index = 0
        repeat {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            index += 1
        } while try await client.tasks.list()
            .filter({$0.serviceId == service.id && $0.status.state == .running})
            .count < replicas && index < 15
        
        // TODO: test with tty = false and timestamps = true once bug fixed
        do {
        for try await line in try await client.services.logs(service: service, timestamps: true) {
            XCTAssert(line.timestamp != Date.distantPast, "Ensure timestamp is parsed properly")
            //XCTAssert(line.source == .stdout, "Ensure stdout is properly detected")
        }
        }
        catch(let error) {
            print("\n••••• BOOM! \(error)")
        }
        
        try await client.services.remove(service.id)
    }
    
    func textZzzLeaveSwarm() async throws {
        try await client.swarm.leave()
    }
}
