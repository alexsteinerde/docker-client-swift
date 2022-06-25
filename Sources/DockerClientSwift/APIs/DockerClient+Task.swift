import Foundation

extension DockerClient {
    
    /// APIs related to tasks (containers running on a Swarm).
    public var tasks: TasksAPI {
        .init(client: self)
    }
    
    public struct TasksAPI {
        fileprivate var client: DockerClient
        
        /// Lists all the tasks running in the Docker Swarm cluster.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns a list of `SwarmTask` instances.
        public func list() async throws -> [SwarmTask] {
            return try await client.run(ListTasksEndpoint())
        }
        
        /// Gets a Swarm task by its id.
        /// - Parameter id: ID of a task that should be fetched.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Return the `SwarmTask`.
        public func get(_ id: String) async throws -> SwarmTask {
            return try await client.run(InspectTaskEndpoint(id: id))
        }
        
        /// Gets the logs of a Docker Swarm task.
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
            
            var tty: Bool!
            if let hasTty = task.spec.containerSpec.tty {
                tty = hasTty
            }
            else {
                let image = try await self.client.images.get(task.spec.containerSpec.image)
                tty = image.containerConfig.tty
            }
            
            let response = try await client.run(
                endpoint,
                // Arbitrary timeouts.
                // TODO: should probably make these configurable
                timeout: follow ? .hours(12) : .seconds(60),
                hasLengthHeader: !tty
            )
            return try await endpoint.map(response: response, tty: task.spec.containerSpec.tty ?? false)
        }
    
    }
}
