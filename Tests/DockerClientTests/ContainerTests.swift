import XCTest
@testable import DockerClient
import Logging

final class ContainerTests: XCTestCase {
    func testListContainers() throws {
        let client = DockerClient.testable()
        let image = try client.images.pullImage(byName: "hello-world", tag: "latest").wait()
        let _ = try! client.containers.createContainer(image: image).wait()
        
        let containers = try client.containers.list(all: true).wait()
    
        XCTAssert(containers.count >= 1)
    }
    
    func testStartingContainerAndRetrievingLogs() throws {
        let client = DockerClient.testable()
        let image = try client.images.pullImage(byName: "hello-world", tag: "latest").wait()
        let container = try! client.containers.createContainer(image: image).wait()
        try container.start(on: client).wait()
        let output = try container.logs(on: client).wait()
        
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
}
