import XCTest
@testable import DockerClientSwift
import Logging

final class ServiceTests: XCTestCase {
    
    var client: DockerClient!
    
    override func setUp() async throws {
        client = DockerClient.testable()
        if (try? await client.images.get("nginx:latest")) == nil {
            _ = try await client.images.pull(byName: "nginx", tag: "latest")
        }
        
        try? await client.swarm.leave(force: true)
        let _ = try! await client.swarm.initSwarm(config: SwarmConfig())
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
            mode: .replicated(1)
        )
        let service = try await client.services.create(spec: spec)
        
        let services = try await client.services.list()
        XCTAssert(services.count >= 1)
        
        try await client.services.remove(service.id)
    }
    
    func testCreateService() async throws {
        let name = UUID().uuidString
        let spec = ServiceSpec(
            name: name,
            taskTemplate: .init(
                containerSpec: .init(image: "nginx:latest"),
                resources: .init(
                    limits: .init(memoryBytes: UInt64(64 * 1024 * 1024))
                )
            ),
            mode: .replicated(1),
            endpointSpec: .init(ports: [.init(name: "HTTP", targetPort: 80, publishedPort: 8000)])
        )
        let service = try await client.services.create(spec: spec)
        
        XCTAssert(service.spec.name == name, "Ensure custom service name is set")
        XCTAssert(service.spec.taskTemplate.resources?.limits?.memoryBytes == 64 * 1024 * 1024, "Ensure memory limit is set")
        
        try await client.services.remove(service.id)
    }
    
    func testCreateServiceWithNetandSecret() async throws {
        let name = UUID().uuidString
        let network = try await client.networks.create(spec: .init(name: name, driver: "overlay"))
        let secret = try await client.secrets.create(spec: .init(name: name, value: "blublublu"))
        let spec = ServiceSpec(
            name: name,
            taskTemplate: .init(
                containerSpec: .init(
                    image: "nginx:latest",
                    mounts: [
                        .volume(name: "myVolume", to: "/mnt"),
                        .tmpFs(options: .init(sizeBytes: UInt64(64*1024*1024)))
                    ],
                    secrets: [.init(secret)]
                ),
                resources: .init(
                    limits: .init(memoryBytes: UInt64(64 * 1024 * 1024))
                )
            ),
            mode: .replicated(1),
            networks: [.init(target: network.id)],
            endpointSpec: .init(ports: [.init(name: "HTTP", targetPort: 80, publishedPort: 8000)])
        )
        do {
            let service = try await client.services.create(spec: spec)
        
            try await client.services.remove(service.id)
        }
        catch(let error) {
            print("\n•••• BOOM! \(error)")
            throw error
        }
    }
    
    func testUpdateService() async throws {
        let name = UUID().uuidString
        var spec = ServiceSpec(
            name: name,
            taskTemplate: .init(
                containerSpec: .init(image: "nginx:latest", tty: false)
            ),
            mode: .replicated(1)
        )
        let service = try await client.services.create(spec: spec)
        
        spec.mode = .replicated(2)
        let updated = try await client.services.update(service: service, version: service.version.index, spec: spec)
        
        XCTAssertTrue(updated.version.index > service.version.index)
        XCTAssert(
            updated.spec.mode.replicated != nil && updated.spec.mode.replicated!.replicas == 2,
            "Ensure number of replicas has been updated"
        )
        
        try await client.services.remove(service.id)
    }
    
    func testGetServiceLogs() async throws {
        let name = UUID().uuidString
        let replicas = 1
        let spec = ServiceSpec(
            name: name,
            taskTemplate: .init(
                containerSpec: .init(image: "nginx:latest", tty: false)
            ),
            mode: .replicated(UInt32(replicas))
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
            throw error
        }
        
        try await client.services.remove(service.id)
    }
    
    func textZzzLeaveSwarm() async throws {
        try await client.swarm.leave()
    }
}
