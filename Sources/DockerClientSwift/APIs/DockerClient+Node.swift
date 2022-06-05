import Foundation
import NIO

extension DockerClient {
    
    /// APIs related to Swarm Nodes.
    public var nodes: NodesAPI {
        .init(client: self)
    }
    
    public struct NodesAPI {
        fileprivate var client: DockerClient
        
        /// Lists all nodes that are member of the current Swarm cluster. Must be connected to a manager Node.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns a list of `SwarmNode` instances.
        public func list() async throws -> [SwarmNode] {
            return try await client.run(ListNodesEndpoint())
        }
        
        /// Returns details about a specific Swarm Node.
        /// - Parameters:
        ///   - id: the ID of the Swarm Node
        public func get(id: String) async throws -> SwarmNode {
            return try await client.run(InspectNodeEndpoint(id: id))
        }
        
        /// Updates a Swarm Node. Must be connected to a manager Node.
        /// - Parameters:
        ///   - id: the ID of the Swarm Node to update.
        ///   - version: the current version fo the Swarm Node config. Can be obtained using `get()`.  This is required to avoid conflicting writes.
        ///   - spec: the `SwarmNodeSpec` config to apply to the Node.
        public func update(id: String, version: String, spec: SwarmNodeSpec) async throws {
            try await client.run(UpdateNodeEndpoint(id: id, version: version, spec: spec))
        }
        
        /// Deletes a Swarm Node.
        /// - Parameters:
        ///   - id: the ID of the Swarm Node to delete.
        ///   - force: force remove a Node from the Swarm
        public func delete(id: String, force: Bool = false) async throws {
            try await client.run(DeleteNodeEndpoint(id: id, force: force))
        }
    }
}
