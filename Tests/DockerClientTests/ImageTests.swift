import XCTest
@testable import DockerClientSwift
import Logging
// Tarscape not available on Linux
//import Tarscape
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
    
    func testPushImage() async throws {
        guard let password = ProcessInfo.processInfo.environment["REGISTRY_PASSWORD"] else {
            fatalError("REGISTRY_PASSWORD is not set")
        }
        var credentials = RegistryAuth(username: "mbarthelemy", password: password)
        let registry = try await client.registries.login(credentials: &credentials)
        
        let tag = UUID().uuidString
        let image = try await client.images.pull(byName: "hello-world", tag: "latest")
        try await client.images.tag(image.id, repoName: "mbarthelemy/tests", tag: tag)
        
        try await client.images.push("mbarthelemy/tests", tag: tag, credentials: credentials)
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
        let image = try await client.images.get("nginx:latest")
        XCTAssert(image.repoTags != nil && image.repoTags!.count > 0 && image.repoTags!.first == "nginx:latest", "Ensure repoTags exists")
    }
    
    func testImageHistory() async throws {
        let image = try await client.images.pull(byName: "nginx", tag: "1.18-alpine")
        let history = try await client.images.history(image.id)
        XCTAssert(history.count > 0 && history.first!.id.starts(with: "sha256"))
    }
    
    func testPruneImages() async throws {
        let image = try await client.images.pull(byName: "nginx", tag: "1.18-alpine")
        
        let pruned = try await client.images.prune(all: true)
        
        let images = try await client.images.list()
        
        XCTAssert(!images.map(\.id).contains(image.id))
        XCTAssert(pruned.reclaimedSpace > 0)
        XCTAssert(pruned.imageIds.contains(image.id))
    }
    
    // Tarscape not available on Linux
    /*func testBuild() async throws {
        let fm = FileManager.default
        let tarContextPath = "/tmp/docker-build.tar"
        try fm.createTar(
            at: URL(fileURLWithPath: tarContextPath),
            from: URL(string: "file:///\(fm.currentDirectoryPath)/Tests")!
        )
        let tar = fm.contents(atPath: tarContextPath)
        let buffer = ByteBuffer.init(data: tar!)
        let buildOutput = try await client.images.build(
            config: .init(
                repoTags: ["build:test"],
                buildArgs: ["TEST": "test"],
                labels: ["test": "value"]
            ),
            context: buffer
        )
        var imageId: String? = nil
        for try await item in buildOutput {
            if item.aux != nil {
                imageId = item.aux!.id
            }
        }
        XCTAssert(imageId != nil, "Ensure built Image ID is returned")
        
        let image = try await client.images.get(imageId!)
        XCTAssert(image.repoTags != nil && image.repoTags!.first == "build:test", "Ensure repo and tag are set")
        XCTAssert(image.containerConfig.labels != nil && image.containerConfig.labels!["test"] == "value", "Ensure labels are set")
        try await client.images.remove(imageId!)
    }*/
}
