import Foundation

// This adds some syntaxic sugar over the Docker container Config=>ExposedPorts property, by
// making it a typed structure, versus the Docker native `"port:protocol": {}` representation
public struct ExposedPortSpec: Codable, Hashable {
    private(set) public var port: UInt16
    private(set) public var `protocol`: PortProtocol
    
    public static func tcp(_ port: UInt16) -> ExposedPortSpec {
        return ExposedPortSpec(port: port, protocol: .tcp)
    }
    
    public static func udp(_ port: UInt16) -> ExposedPortSpec {
        return ExposedPortSpec(port: port, protocol: .udp)
    }
    public static func sctp(_ port: UInt16) -> ExposedPortSpec {
        return ExposedPortSpec(port: port, protocol: .sctp)
    }
    
    public enum PortProtocol: String, Codable {
        case tcp, udp, sctp
    }
    
    struct Empty: Codable{}
    
    init(port: UInt16, protocol: PortProtocol) {
        self.port = port
        self.protocol = `protocol`
    }
}

@propertyWrapper
public struct ExposedPortCoding: OptionalCodableWrapper {
    public var wrappedValue: [ExposedPortSpec]?
    
    public init(wrappedValue: [ExposedPortSpec]?) {
        self.wrappedValue = wrappedValue
    }
}

extension ExposedPortCoding: Decodable {
    public init(from decoder: Swift.Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard let dict = try? container.decode([String:ExposedPortSpec.Empty]?.self) else {
            self.wrappedValue = nil
            return
        }
        self.wrappedValue = []
        for (spec, _) in dict {
            let splat = spec.split(separator: "/")
            if splat.count == 2 {
                guard let port = UInt16(String(splat[0])) else {
                    throw DockerError.corruptedData("expected port number, got '\(splat[0])'")
                }
                guard let proto = ExposedPortSpec.PortProtocol.init(rawValue: String(splat[1])) else {
                    throw DockerError.corruptedData("expected protocol (tcp, udp, sctp), got '\(splat[1])'")
                }
                self.wrappedValue!.append(
                    .init(
                        port: port,
                        protocol: proto
                    )
                )
            }
        }
    }
}

extension ExposedPortCoding: Encodable  {
    public func encode(to encoder: Encoder) throws {
        var dict: [String:ExposedPortSpec.Empty] = [:]
        for item in self.wrappedValue ?? [] {
            dict["\(item.port)/\(item.protocol)"] = ExposedPortSpec.Empty()
        }
        var container = encoder.singleValueContainer()
        try container.encode(dict)
    }
}

@propertyWrapper
public struct PublishedPortCoding: OptionalCodableWrapper {
    public var wrappedValue: [ExposedPortSpec:[ContainerHostConfig.PortBinding]?]?
    
    public init(wrappedValue: [ExposedPortSpec:[ContainerHostConfig.PortBinding]?]?) {
        self.wrappedValue = wrappedValue
    }
}

extension PublishedPortCoding: Decodable {
    public init(from decoder: Swift.Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard let dict = try? container.decode([String:[ContainerHostConfig.PortBinding]?]?.self) else {
            self.wrappedValue = [:]
            return
        }
        self.wrappedValue = [:]
        for (spec, publish) in dict {
            let splat = spec.split(separator: "/")
            if splat.count == 2 {
                guard let port = UInt16(String(splat[0])) else {
                    throw DockerError.corruptedData("expected port number, got '\(splat[0])'")
                }
                guard let proto = ExposedPortSpec.PortProtocol.init(rawValue: String(splat[1])) else {
                    throw DockerError.corruptedData("expected protocol (tcp, udp, sctp), got '\(splat[1])'")
                }
                
                let exposedSpec = ExposedPortSpec(port: port, protocol: proto)
                self.wrappedValue![exposedSpec] = publish
            }
        }
    }
}

extension PublishedPortCoding: Encodable  {
    public func encode(to encoder: Encoder) throws {
        var dict: [String:[ContainerHostConfig.PortBinding]?] = [:]
        for (key, values) in self.wrappedValue ?? [:] {
            dict["\(key.port)/\(key.protocol)"] = values
        }
        var container = encoder.singleValueContainer()
        try container.encode(dict)
    }
}
