import XCTest
@testable import DockerClientSwift
import Logging

final class ContainerTests: XCTestCase {
    
    var client: DockerClient!
    
    override func setUp() {
        client = DockerClient.testable()
    }
    
    override func tearDownWithError() throws {
        try client.syncShutdown()
    }
    
    func testCreateContainers() async throws {
        let _ = try await client.images.pull(byName: "hello-world", tag: "latest")
        let spec = ContainerCreate(
            config: ContainerConfig(image: "hello-world:latest"),
            hostConfig: ContainerHostConfig()
        )
        let name = UUID.init().uuidString
        let container = try await client.containers.create(name: name, spec: spec)
        XCTAssertEqual(container.config.cmd, ["/hello"])
            
        try await client.containers.remove(container.id)
    }
    
    func testUpdateContainers() async throws {
        let name = UUID.init().uuidString
        let _ = try await client.images.pull(byName: "hello-world", tag: "latest")
        let spec = ContainerCreate(
            config: ContainerConfig(image: "hello-world:latest"),
            hostConfig: ContainerHostConfig()
        )
        let container = try await client.containers.create(name: name, spec: spec)
        try await client.containers.start(container.id)
        
        let newConfig = ContainerUpdate(memoryLimit: 64 * 1024 * 1024, memorySwap: 64 * 1024 * 1024)
        try await client.containers.update(container.id, spec: newConfig)
        
        let updated = try await client.containers.get(container.id)
        XCTAssert(updated.hostConfig.memoryLimit == 64 * 1024 * 1024, "Ensure param has been updated")
        
        try await client.containers.remove(container.id)
    }
    
    func testListContainers() async throws {
        let image = try await client.images.pull(byName: "hello-world", tag: "latest")
        let container = try await client.containers.create(image: image)
        
        let containers = try await client.containers.list(all: true)
        XCTAssert(containers.count >= 1)
        XCTAssert(containers.first!.createdAt > Date.distantPast)
            
        try await client.containers.remove(container.id)
    }
    
    func testInspectContainer() async throws {
        let image = try await client.images.pull(byName: "hello-world", tag: "latest")
        let container = try await client.containers.create(image: image)
        let inspectedContainer = try await client.containers.get(container.id)
        
        XCTAssertEqual(inspectedContainer.id, container.id)
        XCTAssertEqual(inspectedContainer.config.cmd, ["/hello"])
    }
    
    func testStartingContainerAndRetrievingLogsNoTty() async throws {
        let image = try await client.images.pull(byName: "hello-world", tag: "latest")
        let container = try await client.containers.create(
            name: nil,
            spec: ContainerCreate(
                config: ContainerConfig(image: image.id, tty: false),
                hostConfig: .init())
        )
        try await client.containers.start(container.id)
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        var output = ""
        for try await line in try await client.containers.logs(container: container, timestamps: true) {
            XCTAssert(line.timestamp != Date.distantPast, "Ensure timestamp is parsed properly")
            XCTAssert(line.source == .stdout, "Ensure stdout is properly detected")
            output += line.message + "\n"
        }
        // arm64v8 or amd64
        XCTAssertEqual(
            output,
        """

        Hello from Docker!
        This message shows that your installation appears to be working correctly.
        
        To generate this message, Docker took the following steps:
         1. The Docker client contacted the Docker daemon.
         2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
            (amd64)
         3. The Docker daemon created a new container from that image which runs the
            executable that produces the output you are currently reading.
         4. The Docker daemon streamed that output to the Docker client, which sent it
            to your terminal.
        
        To try something more ambitious, you can run an Ubuntu container with:
         $ docker run -it ubuntu bash
        
        Share images, automate workflows, and more with a free Docker ID:
         https://hub.docker.com/
        
        For more examples and ideas, visit:
         https://docs.docker.com/get-started/
        
        
        """
        )
        
        try await client.containers.remove(container.id)
    }
    
    // Log entries parsing is quite different depending on whether the container has a TTY
    func testStartingContainerAndRetrievingLogsTty() async throws {
        let image = try await client.images.pull(byName: "hello-world", tag: "latest")
        let container = try await client.containers.create(
            name: nil,
            spec: ContainerCreate(
                config: ContainerConfig(image: image.id, tty: true),
                hostConfig: .init())
        )
        try await client.containers.start(container.id)
        
        var output = ""
        for try await line in try await client.containers.logs(container: container, timestamps: true) {
            XCTAssert(line.timestamp != Date.distantPast, "Ensure timestamp is parsed properly")
            XCTAssert(line.source == .stdout, "Ensure stdout is properly detected")
            output += line.message + "\n"
        }
        // arm64v8 or amd64
        XCTAssertEqual(
            output,
        """
        
        Hello from Docker!
        This message shows that your installation appears to be working correctly.
        
        To generate this message, Docker took the following steps:
         1. The Docker client contacted the Docker daemon.
         2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
            (amd64)
         3. The Docker daemon created a new container from that image which runs the
            executable that produces the output you are currently reading.
         4. The Docker daemon streamed that output to the Docker client, which sent it
            to your terminal.
        
        To try something more ambitious, you can run an Ubuntu container with:
         $ docker run -it ubuntu bash
        
        Share images, automate workflows, and more with a free Docker ID:
         https://hub.docker.com/
        
        For more examples and ideas, visit:
         https://docs.docker.com/get-started/
        
        
        """
        )
    }
    
    func testPruneContainers() async throws {
        let image = try await client.images.pull(byName: "nginx", tag: "latest")
        let container = try await client.containers.create(image: image)
        try await client.containers.start(container.id)
        try await client.containers.stop(container.id)
        
        let pruned = try await client.containers.prune()
        let containers = try await client.containers.list(all: true)
        XCTAssert(!containers.map(\.id).contains(container.id))
        XCTAssert(pruned.reclaimedSpace > 0)
        XCTAssert(pruned.containersIds.contains(container.id))
    }
    
    func testPauseUnpauseContainers() async throws {
        let image = try await client.images.pull(byName: "nginx", tag: "latest")
        let container = try await client.containers.create(image: image)
        try await client.containers.start(container.id)
        
        try await client.containers.pause(container.id)
        let paused = try await client.containers.get(container.id)
        XCTAssert(paused.state.paused, "Ensure container is paused")
        
        try await client.containers.unpause(container.id)
        let unpaused = try await client.containers.get(container.id)
        XCTAssert(unpaused.state.paused == false, "Ensure container is unpaused")
        
        try? await client.containers.remove(container.id, force: true)
    }
    
    func testRenameContainer() async throws {
        let image = try await client.images.pull(byName: "nginx", tag: "latest")
        let container = try await client.containers.create(image: image)
        try await client.containers.start(container.id)
        try await client.containers.rename(container.id, to: "renamed")
        let renamed = try await client.containers.get(container.id)
        XCTAssert(renamed.name == "/renamed", "Ensure container has new name")
        
        try? await client.containers.remove(container.id, force: true)
    }
    
    func testProcessesContainer() async throws {
        let image = try await client.images.pull(byName: "nginx", tag: "latest")
        let container = try await client.containers.create(image: image)
        try await client.containers.start(container.id)
        
        let psInfo = try await client.containers.processes(container.id)
        XCTAssert(psInfo.processes.count > 0, "Ensure processes are parsed")
        
        try? await client.containers.remove(container.id, force: true)
    }
}
