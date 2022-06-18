import XCTest
@testable import DockerClientSwift
import Logging

final class TaskTests: XCTestCase {
    
    var client: DockerClient!
    
    override func setUp() async throws {
        client = DockerClient.testable()
        async let image = try await client.images.pull(byName: "nginx", tag: "latest")
        try? await client.swarm.leave(force: true)
        let _ = try! await client.swarm.initSwarm(config: SwarmConfig())
        try await image
    }
    
    override func tearDownWithError() throws {
        try client.syncShutdown()
        // Remove all services in a Docker system `docker service ls -q | xargs echo`
    }
    
    func testListingTasks() async throws {
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
        
        let tasks = try await client.tasks.list()
        XCTAssert(tasks.count > 0)
    }
    
    
    func testInspectTask() async throws {
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
        let tasks = try await client.tasks.list()
        
        let task = try await client.tasks.get(tasks[0].id)
        XCTAssert(task.serviceId == service.id, "Ensure we properly fetched Service ID")
        
    }
    
    func testGetTaskLogs() async throws {
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
        let tasks = try await client.tasks.list()
        let task = try await client.tasks.get(tasks[0].id)
        
        var containerStatus: SwarmTask.TaskStatus.TaskState = .pending
        var index = 0
        repeat {
            let task = try await client.tasks.get(tasks[0].id)
            containerStatus = task.status.state
            try await Task.sleep(nanoseconds: 1_000_000_000)
            index += 1
        } while containerStatus != .running && index < 15
        
        for try await entry in try await client.tasks.logs(task: task) {
            XCTAssert(entry.timestamp != Date.distantPast, "Ensure timestamp is parsed properly")
        }
    }
    
    func testZzzLeaveSwarm() async throws {
        try await client.swarm.leave(force: true)
    }
}
