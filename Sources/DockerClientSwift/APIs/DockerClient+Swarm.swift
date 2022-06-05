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
        
        /// Enable Swarm mode on the Docker daemon we are connected to
        /// - Returns: Returns the Swarm ID.
        public func initSwarm(config: SwarmConfig = .init()) async throws -> String {
            let response = try await client.run(InitSwarmEndpoint(config: config))
            return response
        }
        
        /// Add the Docker daemon we are connected to, to an existing Docker Swarm cluster
        public func join(config: SwarmJoin) async throws {
            try await client.run(JoinSwarmEndpoint(config: config))
        }
        
        /// Leave the Docker Swarm cluster and disable Swarm mode
        public func leave(force: Bool = false) async throws {
            try await client.run(LeaveSwarmEndpoint(force: force))
        }
        
        /// Update a Swarm cluster. Connected Docker daemon must be a manager.
        /// - Parameters:
        ///   - spec: the updated Swarm Spec.
        ///   - version: the current Swarm config version (can be bntained from `get()`).
        ///   - rotateWorkerToken:
        ///   - rotateManagerToken:
        ///   - rotateManagerUnlockKey:
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
