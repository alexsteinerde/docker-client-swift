import Foundation

/*@propertyWrapper
public struct ExposedPortCoding {
    public var wrappedValue: ExposedPort
    
    public init(wrappedValue: Default.DefaultValue) {
        self.wrappedValue = wrappedValue
    }
}

extension ExposedPortCoding: Decodable where Default.DefaultValue: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = (try? container.decode(Default.DefaultValue.self)) ?? Default.defaultValue
    }
}

extension ExposedPortCoding: Encodable where Default.DefaultValue: Encodable {
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}*/


public struct ExposedPortSpec: Codable {
    private(set) public var port: UInt16
    private(set) public var `protocol`: PortProtocol
    
    public static func tcp(_ port: UInt16) {
        return ExposedPortSpec(port: port, protocol: .tcp)
    }
    
    public static func udp(_ port: UInt16) {
        return ExposedPortSpec(port: port, protocol: .udp)
    }
    public static func sctp(_ port: UInt16) {
        return ExposedPortSpec(port: port, protocol: .sctp)
    }
    
    public enum PortProtocol: String, Codable {
        case tcp, udp, sctp
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = (try? container.decode(Default.DefaultValue.self)) ?? Default.defaultValue
    }
    
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}
