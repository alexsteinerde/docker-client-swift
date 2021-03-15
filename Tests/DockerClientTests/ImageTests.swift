import XCTest
@testable import DockerClientSwift
import Logging

final class ImageTests: XCTestCase {
    func testPullImage() throws {
        let client = DockerClient.testable()
        let image = try client.images.pullImage(byName: "hello-world", tag: "latest").wait()
        
        XCTAssertTrue(image.repositoryTags.contains(where: { $0.repository == "hello-world" && $0.tag == "latest"}))
    }
    
    func testListImage() throws {
        let client = DockerClient.testable()
        let _ = try client.images.pullImage(byName: "hello-world", tag: "latest").wait()
        
        let images = try client.images.list().wait()
        
        XCTAssert(images.count >= 1)
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
    
    func testInspectImage() throws {
        let client = DockerClient.testable()
    
        XCTAssertNoThrow(try client.images.get(imageByNameOrId: "nginx:latest").wait())
    }
}
