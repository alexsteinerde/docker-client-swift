import NIO
import NIOHTTP1
import Foundation
import AsyncHTTPClient

class GetServiceLogsEndpoint: GetContainerLogsEndpoint {
    typealias Body = NoBody
    typealias Response = AsyncThrowingStream<ByteBuffer, Error>
        
    private let serviceId: String
    private let details: Bool
    
    init(serviceId: String, details: Bool, stdout: Bool, stderr: Bool, timestamps: Bool, follow: Bool, tail: String, since: Date, until: Date) {
        self.serviceId = serviceId
        self.details = details
        super.init(
            containerId: self.serviceId,
            stdout: stdout,
            stderr: stderr,
            timestamps: timestamps,
            follow: follow,
            tail: tail,
            since: since,
            until: until
        )
    }
    
    override var path: String {
        """
        services/\(serviceId)/logs\
        ?details\(details)\
        &stdout=\(stdout)\
        &stderr=\(stderr)\
        &follow=\(follow)\
        &tail=\(tail)\
        &timestamps=\(timestamps)\
        &since=\(since)\
        &until=\(until)
        """
    }
}
