import NIO
import NIOHTTP1
import Foundation

class GetTaskLogsEndpoint: GetContainerLogsEndpoint {
    typealias Body = NoBody
    typealias Response = AsyncThrowingStream<ByteBuffer, Error>
    
    private let taskId: String
    private let details: Bool
    
    override var path: String {
        """
        tasks/\(taskId)/logs\
        ?details=\(details)\
        &stdout=\(stdout)\
        &stderr=\(stderr)\
        &follow=\(follow)\
        &tail=\(tail)\
        &timestamps=\(timestamps)\
        &since=\(since)\
        &until=\(until)
        """
    }
    
    init(taskId: String, details: Bool, stdout: Bool, stderr: Bool, timestamps: Bool, follow: Bool, tail: String, since: Date, until: Date) {
        self.taskId = taskId
        self.details = details
        super.init(
            containerId: self.taskId,
            stdout: stdout,
            stderr: stderr,
            timestamps: timestamps,
            follow: follow,
            tail: tail,
            since: since,
            until: until
        )
    }
}
