import NIO
import NIOHTTP1
import WebSocketKit
import Foundation

class ContainerAttachEndpoint {
    typealias Body = NoBody
    typealias Response = AsyncThrowingStream<ByteBuffer, Error>
    
    var method: HTTPMethod = .GET
    
    private let nameOrId: String
    let stream: Bool
    let stdin: Bool
    let stdout: Bool
    let stderr: Bool

    var path: String {
        """
        containers/\(nameOrId)/attach/ws\
        ?stdin=\(stdin)\
        &stdout=\(stdout)\
        &stderr=\(stderr)\
        &stream=\(stream)
        """
    }

    
    init(nameOrId: String, stream: Bool, stdin: Bool, stdout: Bool, stderr: Bool) {
        self.nameOrId = nameOrId
        self.stream = stream
        self.stdin = stdin
        self.stdout = stdout
        self.stderr = stderr
    }
    
}
