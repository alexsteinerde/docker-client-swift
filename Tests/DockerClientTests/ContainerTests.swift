import XCTest
@testable import DockerClientSwift
import Logging

final class ContainerTests: XCTestCase {
    
    var client: DockerClient!
    
    override func setUp() {
        client = DockerClient.testable()
    }
    
    override func tearDownWithError() throws {
        try! client.syncShutdown()
    }
    
    func testCreateContainers() throws {
        let image = try client.images.pullImage(byName: "hello-world", tag: "latest").wait()
        let container = try client.containers.createContainer(image: image).wait()
        
        XCTAssertEqual(container.command, "/hello")
    }
    
    func testListContainers() throws {
        let image = try client.images.pullImage(byName: "hello-world", tag: "latest").wait()
        let _ = try client.containers.createContainer(image: image).wait()
        
        let containers = try client.containers.list(all: true).wait()
        
        XCTAssert(containers.count >= 1)
    }
    
    func testInspectContainer() throws {
        let image = try client.images.pullImage(byName: "hello-world", tag: "latest").wait()
        let container = try client.containers.createContainer(image: image).wait()
        
        let inspectedContainer = try client.containers.get(containerByNameOrId: container.id.value).wait()
        
        XCTAssertEqual(inspectedContainer.id, container.id)
        XCTAssertEqual(inspectedContainer.command, "/hello")
    }
    
    func testStartingContainerAndRetrievingLogs() throws {
        let image = try client.images.pullImage(byName: "hello-world", tag: "latest").wait()
        let container = try client.containers.createContainer(image: image).wait()
        try container.start(on: client).wait()
        let output = try container.logs(on: client).wait()
        // Depending on CPU architecture, step 2 of the log output may by:
        // 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
        //    (amd64)
        // or
        // 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
        //    (arm64v8)
        //
        // Just check the lines before and after this line
        let expectedOutputPrefix = """
            
            Hello from Docker!
            This message shows that your installation appears to be working correctly.
            
            To generate this message, Docker took the following steps:
             1. The Docker client contacted the Docker daemon.
             2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
            """
        let expectedOutputSuffix = """
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
        
        XCTAssertTrue(
            output.hasPrefix(expectedOutputPrefix),
            """
            "\(output)"
            did not start with
            "\(expectedOutputPrefix)"
            """
        )
        XCTAssertTrue(
            output.hasSuffix(expectedOutputSuffix),
            """
            "\(output)"
            did not end with
            "\(expectedOutputSuffix)"
            """
        )
    }
    
    func testPruneContainers() throws {
        let image = try client.images.pullImage(byName: "nginx", tag: "latest").wait()
        let container = try client.containers.createContainer(image: image).wait()
        try container.start(on: client).wait()
        try container.stop(on: client).wait()
        
        let pruned = try client.containers.prune().wait()
        
        let containers = try client.containers.list(all: true).wait()
        XCTAssert(!containers.map(\.id).contains(container.id))
        XCTAssert(pruned.reclaimedSpace > 0)
        XCTAssert(pruned.containersIds.contains(container.id))
    }
}
