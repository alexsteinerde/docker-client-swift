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
    
    /// The status of the service's tasks.
    /// Provided only when requested as part of a ServiceList operation.
    public let serviceStatus: ServiceStatus? = nil
    
    /// The status of the service when it is in one of ReplicatedJob or GlobalJob modes.
    /// Absent on Replicated and Global mode services. 
    public let jobStatus: JobStatus? = nil
    
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
        /// Properties that can be configured to access and load balance a service.
        public let spec: ServiceEndpointSpec?
        
        public let ports: [ServiceEndpointSpec.EndpointPortConfig]?
        public let virtualIps: [EndpointVirtualIp]?
        
        enum CodingKeys: String, CodingKey {
            case spec = "Spec"
            case ports = "Ports"
            case virtualIps = "VirtualIps"
        }
        
        public struct EndpointVirtualIp: Codable {
            /// The ID of the Docker Network
            public let networkId: String
            
            /// The IP address of the container endpoint on this Docker Network.
            public let address: String
            
            enum CodingKeys: String, CodingKey {
                case networkId = "NetworkID"
                case address = "Addr"
            }
        }
    }
    
    public struct UpdateStatus: Codable {
        public let state: ServiceUpdateState
        public let startedAt: Date
        public let completedAt: Date
        public let message: String?
        
        enum CodingKeys: String, CodingKey {
            case state = "State"
            case startedAt = "StartedAt"
            case completedAt = "CompletedAt"
            case message = "Message"
        }
        
        public enum ServiceUpdateState: String, Codable {
            case updating, paused, completed
        }
        
    }
    
    public struct ServiceStatus: Codable {
        /// The number of tasks for the service currently in the Running state.
        public let runningTasks: UInt64
        
        /// The number of tasks for the service desired to be running.
        /// For replicated services, this is the replica count from the service spec.
        /// For global services, this is computed by taking count of all tasks for the service with a Desired State other than Shutdown.
        public let desiredTasks: UInt64
        
        /// The number of tasks for a job that are in the Completed state.
        /// This field must be cross-referenced with the service type, as the value of 0 may mean the service is not in a job mode, or it may mean the job-mode service has no compeleted tasks yet.
        public let completedTasks: UInt64
        
        enum CodingKeys: String, CodingKey {
            case runningTasks = "RunningTasks"
            case desiredTasks = "DesiredTasks"
            case completedTasks = "CompletedTasks"
        }
    }
    
    public struct JobStatus: Codable {
        /// The version number of the object such as node, service, etc. This is needed to avoid conflicting writes.
        /// The client must send the version number along with the modified specification when updating these objects.
        public let jobIteration: SwarmVersion
        
        /// The last time, as observed by the server, that this job was started.
        public let lastExecution: Date
        
        enum CodingKeys: String, CodingKey {
            case jobIteration = "JobIteration"
            case lastExecution = "LastExecution"
        }
    }
}


extension Service: Codable {}
