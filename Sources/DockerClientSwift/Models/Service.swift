import Foundation

/// Representation of a service.
/// Some actions can be performed on an instance.
public struct Service {
    
    public let id: String
    public let createdAt: Date?
    public let updatedAt: Date?
    
    /// The version number of the service. This is needed to avoid conflicting writes.
    /// The client must send the version number along with the modified specification when updating a service.
    public let version: SwarmVersion
    
    /// User modifiable configuration for a service.
    public let spec: ServiceSpec
    
    public let endpoint: Endpoint
    
    /// The status of a service update.
    public let updateStatus: UpdateStatus? = nil
    
    /// The status of the service's tasks. Provided only when requested as part of a ServiceList operation.
    public let serviceStatus: ServiceStatus? = nil
    
    /// The status of the service when it is in one of ReplicatedJob or GlobalJob modes.
    /// Absent on Replicated and Global mode services. 
    public let jobStatus: JobStatus?
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case createdAt = "CreatedAt"
        case updatedAt = "UpdatedAt"
        case version = "Version"
        case spec = "Spec"
        case endpoint = "Endpoint"
        case updateStatus = "UpdateStatus"
        case serviceStatus = "ServiceStatus"
        case jobStatus = "JobStatus"
    }
    
    public struct Endpoint: Codable {
        //public let spec: ServiceEndpointSpec
        // public let ports
        // public let virtualIps
    }
    
    public struct UpdateStatus: Codable {
        
    }
    
    public struct ServiceStatus: Codable {
        
    }
    
    public struct JobStatus: Codable {
        
    }
}


extension Service: Codable {}
