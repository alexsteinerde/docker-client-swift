import XCTest
@testable import DockerClientSwift
import Logging

final class ImageTests: XCTestCase {
    
    var client: DockerClient!
    
    override func setUp() {
        client = DockerClient.testable()
    }
    
    override func tearDownWithError() throws {
        try client.syncShutdown()
    }
    
    func testPullImage() async throws {
        let image = try await client.images.pullImage(byName: "hello-world", tag: "latest")
        
        XCTAssertTrue(image.repositoryTags.contains(where: { $0.repository == "hello-world" && $0.tag == "latest"}))
    }
    
    func testListImage() async throws {
        let _ = try await client.images.pullImage(byName: "hello-world", tag: "latest")
        
        let images = try await client.images.list()
        
        XCTAssert(images.count >= 1)
        
        for i in images {
            XCTAssert(i.created < Date(), "Ensure image create date is parsed properly")
        }
    }
    
    func testParsingRepositoryTagSuccessfull() {
        let rt = Image.RepositoryTag("hello-world:latest")
        
        XCTAssertEqual(rt?.repository, "hello-world")
        XCTAssertEqual(rt?.tag, "latest")
    }
    
    func testParsingRepositoryTagThreeComponents() {
        let rt = Image.RepositoryTag("hello-world:latest:anotherone")
        
        XCTAssertNil(rt)
    }
    
    func testParsingRepositoryTagOnlyRepo() {
        let rt = Image.RepositoryTag("hello-world")
        
        XCTAssertEqual(rt?.repository, "hello-world")
        XCTAssertNil(rt?.tag)
    }
    
    func testParsingRepositoryTagWithDigest() {
        let rt = Image.RepositoryTag("sha256:89b647c604b2a436fc3aa56ab1ec515c26b085ac0c15b0d105bc475be15738fb")
        
        XCTAssertNil(rt)
    }
    
    func testInspectImage() async throws {
        XCTAssertNoThrow(Task(priority: .medium) { try await client.images.get(imageByNameOrId: "nginx:latest") })
    }
    
    func testPruneContainers() async throws {
        let image = try await client.images.pullImage(byName: "nginx", tag: "1.18-alpine")
        
        let pruned = try await client.images.prune(all: true)
        
        let images = try await client.images.list()
        
        XCTAssert(!images.map(\.id).contains(image.id.value))
        XCTAssert(pruned.reclaimedSpace > 0)
        XCTAssert(pruned.imageIds.contains(image.id))
    }
}
