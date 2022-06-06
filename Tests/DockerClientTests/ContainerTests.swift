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
        let image = try await client.images.pullImage(byName: "hello-world", tag: "latest")
        let container = try await client.containers.createContainer(image: image)

        XCTAssertEqual(container.config.Cmd, ["/hello"])
    }
    
    func testListContainers() async throws {
        let image = try await client.images.pullImage(byName: "hello-world", tag: "latest")
        let _ = try await client.containers.createContainer(image: image)
        
        let containers = try await client.containers.list(all: true)
    
        XCTAssert(containers.count >= 1)
    }
    
    func testInspectContainer() async throws {
        let image = try await client.images.pullImage(byName: "hello-world", tag: "latest")
        let container = try await client.containers.createContainer(image: image)
        
        let inspectedContainer = try await client.containers.get(container.id)
        
        XCTAssertEqual(inspectedContainer.id, container.id)
        XCTAssertEqual(inspectedContainer.config.Cmd, ["/hello"])
    }
    
    func testStartingContainerAndRetrievingLogs() async throws {
        let image = try await client.images.pullImage(byName: "hello-world", tag: "latest")
        let container = try await client.containers.createContainer(image: image)
        try await container.start(on: client)
        
        var output = ""
        for try await line in try await client.containers.logs(container: container, timestamps: true) {
            output += line.message + "\n"
            print("\n*** log message=\(line)")
        }
        print("\n••••• OUTPUT=\(output)")
        // arm64v8 or amd64
        XCTAssertEqual(
            output,
        """

        Hello from Docker!
        This message shows that your installation appears to be working correctly.
        
        To generate this message, Docker took the following steps:
         1. The Docker client contacted the Docker daemon.
         2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
            (arm64v8)
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
        let image = try await client.images.pullImage(byName: "nginx", tag: "latest")
        let container = try await client.containers.createContainer(image: image)
        try await container.start(on: client)
        try await container.stop(on: client)
        
        let pruned = try await client.containers.prune()
        
        let containers = try await client.containers.list(all: true)
        XCTAssert(!containers.map(\.id).contains(container.id))
        XCTAssert(pruned.reclaimedSpace > 0)
        XCTAssert(pruned.containersIds.contains(container.id))
    }
}
