import Foundation

/// A task is a container that runs as part of a `Service` on a docker Swarm cluster.
public struct SwarmTask: Codable {
    /// The ID of the task.
    public let id: String
    
    public let version: SwarmVersion
    
    public let createdAt: Date
    
    public let updatedAt: Date
    
    /// Name of the task.
    public let name: String
    
    /// User-defined key/value metadata.
    public let labels: [String:String]
    
    /// User modifiable task configuration.
    public let spec: ServiceSpec.TaskTemplate
    
    /// The ID of the `Service` this task is part of.
    public let serviceId: String
    
    public let slot: Int
    
    /// The ID of the node that this task is on.
    public let nodeId: String
    
    public let status: TaskStatus
    
    public let assignedGenericResources: [GenericResource]
    
    public let desiredState: TaskStatus.TaskState
    
    public let jobIteration: SwarmVersion?
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case version = "Version"
        case createdAt = "CreatedAt"
        case updatedAt = "UpdatedAt"
        case name = "Name"
        case labels = "Labels"
        case spec = "Sepc"
        case serviceId = "ServiceID"
        case slot = "Slot"
        case nodeId = "NodeID"
        case status = "Status"
        case assignedGenericResources = "AssignedGenericResources"
        case desiredState = "DesiredState"
        case jobIteration = "JobIteration"
    }
    
    /*public struct TaskSpec: Codable {
        public let containerSpec: ContainerSpec
        
        /// public let NetworkAttachmentSpec: NetworkAttachmentSpec
        
        public let resources: ServiceSpec.TaskTemplate.Resources
        
        public let restartPolicy: ServiceRestartPolicy
        
        // TODO: implement
        //public let placement: Placement
        
        public let forceUpdate: Int
        
        public let runtime: String
        
        public let networks: [NetworkAttachmentConfig]?
        
        public let logDriver: 
        enum CodingKeys: String, CodingKey {
            case containerSpec = "ContainerSpec"
        }
    }*/
    
    public struct TaskStatus: Codable {
    
        public let timestamp: Date
        
        public let state: TaskState
        
        public let message: String?
        
        public let error: String?
        
        public let containerStatus: ContainerStatus
        
        enum CodingKeys: String, CodingKey {
            case timestamp = "Timestamp"
            case state = "State"
            case message = "Message"
            case error = "Err"
            case containerStatus = "ContainerStatus"
        }
        
        public enum TaskState: String, Codable {
            case new, allocated, pending, assigned, accepted, preparing, ready, starting, running, complete, shutdown, failed, rejected, remove, orphaned
        }
        
        public struct ContainerStatus: Codable {
            public let containerId: String
            
            public let pid: UInt64
            
            public let exitCode: Int?
            
            enum CodingKeys: String, CodingKey {
                case containerId = "ContainerID"
                case pid = "PID"
                case exitCode = "ExitCode"
            }
        }
    }
}
