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
    private let since: Int64
    private let until: Int64
    
    init(containerId: String, stdout: Bool, stderr: Bool, timestamps: Bool, follow: Bool, tail: String, since: Date, until: Date) {
        self.containerId = containerId
        self.stdout = stdout
        self.stderr = stderr
        self.timestamps = timestamps
        self.follow = follow
        self.tail = tail
        // TODO: looks like Swift adds an extra zero compared to `docker logs --since=xxx`
        self.since = Int64(since.timeIntervalSince1970)
        self.until = Int64(until.timeIntervalSince1970)
    }
    
    var path: String {
        """
        containers/\(containerId)/logs\
        ?stdout=\(stdout)\
        &stderr=\(stderr)\
        &follow=\(follow)\
        &tail=\(tail)\
        &timestamps=\(timestamps)\
        &since=\(since)\
        &until=\(until)
        """
    }
}
