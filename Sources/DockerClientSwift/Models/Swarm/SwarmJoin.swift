import Foundation

/// Configuration for a Docker daemon to join an exisiting Swarm as a node.
public struct SwarmJoin: Codable {
    public init(advertiseAddr: String? = nil, dataPathAddr: String? = nil, joinToken: String, listenAddr: String = "0.0.0.0", remoteAddrs: [String]) {
        self.advertiseAddr = advertiseAddr
        self.dataPathAddr = dataPathAddr
        self.joinToken = joinToken
        self.listenAddr = listenAddr
        self.remoteAddrs = remoteAddrs
    }
    
    /// Externally reachable address advertised to other nodes. This can either be an address/port combination in the form 192.168.1.1:4567, or an interface followed by a port number, like eth0:4567.
    /// If the port number is omitted, the port number from the listen address is used. If `advertiseAddr` is not specified, it will be automatically detected when possible.
    public var advertiseAddr: String?
    
    /// Address or interface to use for data path traffic (format: `<ip|interface>`), for example, 192.168.1.1, or an interface, like eth0.
    /// If `dataPathAddr` is unspecified, the same addres as `advertiseAddr` is used.
    public var dataPathAddr: String?
    
    /// Secret token for joining this Swarm. Required.
    public var joinToken: String
    
    /// Listen address used for inter-manager communication if the node gets promoted to manager, as well as determining the networking interface used for the VXLAN Tunnel Endpoint (VTEP).
    public var listenAddr: String = "0.0.0.0"
    
    /// Addresses of manager nodes already participating in the swarm. Required.
    /// Format of entries: `ip:port` or `hostname:port`
    public var remoteAddrs: [String]
    
    enum CodingKeys: String, CodingKey {
        case advertiseAddr = "AdvertiseAddr"
        case dataPathAddr = "DataPathAddr"
        case joinToken = "JoinToken"
        case listenAddr = "ListenAddr"
        case remoteAddrs = "RemoteAddrs"
    }
}
