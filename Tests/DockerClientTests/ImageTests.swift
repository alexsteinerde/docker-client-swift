import XCTest
@testable import DockerClientSwift
import Logging

final class ImageTests: XCTestCase {
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
}
