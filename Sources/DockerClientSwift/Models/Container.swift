import Foundation
/// Representation of a container.
/// Some actions can be performed on an instance.
public struct Container {
    public var id: Identifier<Container>
    public var image: Image
    public var createdAt: Date
    public var names: [String]
    public var state: String
    public var command: String
}

extension Container: Codable {}

/// Representation of a port binding
public struct PortBinding {
    public var hostIP: String
    public var hostPort: UInt16
    public var containerPort: UInt16
    public var networkProtocol: NetworkProtocol
    
    /// Creates a PortBinding
    ///
    /// - Parameters:
    ///   - hostIP: The host IP address to map the connection to. Default `0.0.0.0`.
    ///   - hostPort: The port on the Docker host to map connections to. `0` means map to a random available port. Default `0`.
    ///   - containerPort: The port on the container to map connections from.
    ///   - networkProtocol: The protocol (`tcp`/`udp`) to bind. Default `tcp`.
    public init(hostIP: String = "0.0.0.0", hostPort: UInt16=0, containerPort: UInt16, networkProtocol: NetworkProtocol = .tcp) {
        self.hostIP = hostIP
        self.hostPort = hostPort
        self.containerPort = containerPort
        self.networkProtocol = networkProtocol
    }
}

public enum NetworkProtocol: String {
    case tcp
    case udp
}
