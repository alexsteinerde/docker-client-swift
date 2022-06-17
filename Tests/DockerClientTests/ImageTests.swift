import XCTest
@testable import DockerClientSwift
import Logging
import Tarscape
import NIO

final class ImageTests: XCTestCase {
    
    var client: DockerClient!
    
    override func setUp() {
        client = DockerClient.testable()
    }
    
    override func tearDownWithError() throws {
        try client.syncShutdown()
    }
    
    func testDeleteImage() async throws {
        let image = try await client.images.pull(byName: "hello-world", tag: "latest")
        try await client.images.remove(image.id, force: true)
    }
    
    func testPullImage() async throws {
        let image = try await client.images.pull(byName: "hello-world", tag: "latest")
        
        XCTAssertTrue(image.repoTags!.first == "hello-world:latest")
    }
    
    func testListImage() async throws {
        let _ = try await client.images.pull(byName: "hello-world", tag: "latest")
        
        let images = try await client.images.list()
        
        XCTAssert(images.count >= 1)
    }
    
    /*func testParsingRepositoryTagSuccessfull() {
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
    }*/
    
    func testInspectImage() async throws {
        XCTAssertNoThrow(Task(priority: .medium) { try await client.images.get("nginx:latest") })
    }
    
    func testPruneImages() async throws {
        let image = try await client.images.pull(byName: "nginx", tag: "1.18-alpine")
        
        let pruned = try await client.images.prune(all: true)
        
        let images = try await client.images.list()
        
        XCTAssert(!images.map(\.id).contains(image.id))
        XCTAssert(pruned.reclaimedSpace > 0)
        XCTAssert(pruned.imageIds.contains(image.id))
    }
    
    func testBuild() async throws {
        let tarContextPath = "/tmp/docker-build.tar"
        try FileManager.default.createTar(
            at: URL(fileURLWithPath: tarContextPath),
            from: URL(string: "file:///Users/matthieubarthelemy/git/docker-client-swift/Tests")!
        )
        let tar = FileManager.default.contents(atPath: tarContextPath)
        let buffer = ByteBuffer.init(data: tar!)
        let buildOutput = try await client.images.build(
            config: .init(repoTags: ["build:test"]),
            context: buffer
        )
        var imageId: String? = nil
        for try await item in buildOutput {
            if item.aux != nil {
                imageId = item.aux!.id
            }
        }
        XCTAssert(imageId != nil, "Ensure built Image ID is returned")
    }
    
}
