import NIOHTTP1
import Foundation
import AsyncHTTPClient

class GetContainerLogsEndpoint: StreamingEndpoint {   
    typealias Body = NoBody
    typealias Response = HTTPClientResponse.Body
    
    var method: HTTPMethod = .GET
    
    private let containerId: String
    private let follow: Bool
    private let tail: String
    private let stdout: Bool
    private let stderr: Bool
    private let timestamps: Bool
    
    init(containerId: String, stdout: Bool, stderr: Bool, timestamps: Bool, follow: Bool, tail: String) {
        self.containerId = containerId
        self.stdout = stdout
        self.stderr = stderr
        self.timestamps = timestamps
        self.follow = follow
        self.tail = tail
    }
    
    var path: String {
        "containers/\(containerId)/logs?stdout=\(stdout)&stderr=\(stderr)&follow=\(follow)&tail=\(tail)&timestamps=\(timestamps)"
    }
}
