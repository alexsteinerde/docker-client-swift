import Foundation

extension DockerClient {
    
    /// APIs related to images.
    public var services: ServicesAPI {
        .init(client: self)
    }
 
    public struct ServicesAPI {
        fileprivate var client: DockerClient
        
        /// Lists all services running in the Docker Swarm cluster.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns a list of `Service` instances.
        public func list() async throws -> [Service] {
            return try await client.run(ListServicesEndpoint())
        }
        
        /// Gets a service by a given name or id.
        /// - Parameter nameOrId: Name or id of a service that should be fetched.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Return the `Service`.
        public func get(_ nameOrId: String) async throws -> Service {
            return try await client.run(InspectServiceEndpoint(nameOrId: nameOrId))
        }
        
        /// Updates a service with a new image.
        /// - Parameters:
        ///   - service: Instance of a `Service` that should be updated.
        ///   - newImage: Instance of an `Image` that should be used as the new image for the service.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns the updated `Service`.
        /*public func update(service: Service, newImage: Image) async throws -> Service {
            try await client.run(UpdateServiceEndpoint(nameOrId: service.id, name: service.name, version: service.version, image: newImage.id.value))
            return try await self.get(serviceByNameOrId: service.id)
        }*/
        
        
        
        /// Trigger a server-side rollback to the previous service spec
        /// - Parameter nameOrId: Name or id of a service that should be fetched.
        /// - Throws: Errors that can occur when executing the request.
        public func rollback(_ nameOrId: String) async throws {
            let service = try await get(nameOrId)
            try await client.run(UpdateServiceEndpoint(nameOrId: nameOrId, name: "", version: service.version.index, image: nil, rollback: true) )
        }
        
        /// Gets the logs of a service.
        /// - Parameters:
        ///   - service: Instance of a `Service`.
        ///   - details: whether to return service labels.
        ///   - stdErr: whether to return log lines from the standard error.
        ///   - stdOut: whether to return log lines from the standard output.
        ///   - timestamps: whether to return the timestamp of each log line
        ///   - follow: whether to wait for new logs to become available and stream them.
        ///   - tail: number of last existing log lines to return. Default: all.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns  a  sequence of `DockerLogEntry`.
        public func logs(service: Service, details: Bool = false, stdErr: Bool = true, stdOut: Bool = true, timestamps: Bool = true, follow: Bool = false, tail: UInt? = nil, since: Date = .distantPast, until: Date = .distantFuture) async throws -> AsyncThrowingStream<DockerLogEntry, Error> {
            let endpoint = GetServiceLogsEndpoint(
                serviceId: service.id,
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
            return try await endpoint.map(response: response, tty: service.spec.taskTemplate.containerSpec.tty ?? false)
        }
        
        /// Create a new service with a name and an image.
        /// This is the minimal way of creating a new service.
        /// - Parameters:
        ///   - name: Name of the new service.
        ///   - image: Instance of an `Image` for the service.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns the newly created `Service`.
        /*public func create(serviceName name: String, image: Image) async throws -> Service {
            let serviceId = try await client.run(CreateServiceEndpoint(name: name, image: image.id))
            let service = try await client.run(InspectServiceEndpoint(nameOrId: serviceId.ID))
            return service
        }*/
        
        /// Create a new service.
        /// - Parameters:
        ///   - spec: the `ServiceSpec` describing the configuration of the service.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns the newly created `Service` ID.
        public func create(spec: ServiceSpec) async throws -> Service {
            let createResponse = try await client.run(CreateServiceAdvancedEndpoint(spec: spec))
            let service = try await get(createResponse.ID)
            return service
        }
        
        /// Removes an existing service.
        /// - Parameters:
        ///   - nameOrId: Name or Id of the`Service`.
        /// - Throws: Errors that can occur when executing the request.
        public func remove(_ nameOrId: String) async throws {
            try await client.run(RemoveServiceEndpoint(nameOrId: nameOrId))
        }
    }
}

