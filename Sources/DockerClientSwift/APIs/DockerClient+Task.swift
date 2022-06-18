import Foundation

extension DockerClient {
    
    /// APIs related to tasks (containers running on a Swarm).
    public var tasks: TasksAPI {
        .init(client: self)
    }
    
    public struct TasksAPI {
        fileprivate var client: DockerClient
        
        
        /// Gets the logs of a task.
        /// - Parameters:
        ///   - task: Instance of a `SwarmTask`.
        ///   - details: whether to return service labels.
        ///   - stdErr: whether to return log lines from the standard error.
        ///   - stdOut: whether to return log lines from the standard output.
        ///   - timestamps: whether to return the timestamp of each log line
        ///   - follow: whether to wait for new logs to become available and stream them.
        ///   - tail: number of last existing log lines to return. Default: all.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns  a  sequence of `DockerLogEntry`.
        public func logs(task: SwarmTask, details: Bool = false, stdErr: Bool = true, stdOut: Bool = true, timestamps: Bool = true, follow: Bool = false, tail: UInt? = nil, since: Date = .distantPast, until: Date = .distantFuture) async throws -> AsyncThrowingStream<DockerLogEntry, Error> {
            let endpoint = GetTaskLogsEndpoint(
                taskId: task.id,
                details: details,
                stdout: stdOut,
                stderr: stdErr,
                timestamps: timestamps,
                follow: follow,
                tail: tail == nil ? "all" : "\(tail!)",
                since: since,
                until: until
            )
            let response = try await client.run(
                endpoint,
                // Arbitrary timeouts.
                // TODO: should probably make these configurable
                timeout: follow ? .hours(12) : .seconds(60)
            )
            return try await endpoint.map(response: response, tty: false)
        }
    
    }
}
