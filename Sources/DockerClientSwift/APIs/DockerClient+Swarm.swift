import Foundation
import NIO

extension DockerClient {
    
    /// APIs related to Docker Swarm.
    public var swarm: SwarmAPI {
        .init(client: self)
    }
    
    public struct SwarmAPI {
        fileprivate var client: DockerClient
       
        /// Fetches the latest information about a Swarm
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns the `SwarmResponse` and its information.
        public func get() async throws -> InspectSwarmEndpoint.SwarmResponse {
            let response = try await client.run(InspectSwarmEndpoint())
            return response
        }
        
        public func initSwarm(config: SwarmCreate) async throws -> String {
            let response = try await client.run(InitSwarmEndpoint(config: config))
            return response
        }
        
        public func leave(force: Bool = false) async throws {
            try await client.run(LeaveSwarmEndpoint(force: force))
        }
        
        public func update(spec: SwarmSpec, version: UInt64, rotateWorkerToken: Bool = false, rotateManagerToken: Bool = false, rotateManagerUnlockKey: Bool = false) async throws {
            try await client.run(
                UpdateSwarmEndpoint(
                    spec: spec,
                    version: version,
                    rotateWorkerToken: rotateWorkerToken,
                    rotateManagerToken: rotateManagerToken,
                    rotateManagerUnlockKey: rotateManagerUnlockKey
                )
            )
        }
    }
}
