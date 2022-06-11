import Foundation
import NIOHTTP1

struct InspectServiceEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = Service
    var method: HTTPMethod = .GET
    
    
    private let nameOrId: String
    init(nameOrId: String) {
        self.nameOrId = nameOrId
    }
    var path: String {
        "services/\(nameOrId)?insertDefaults=true"
    }
}

internal extension Service {
    struct ServiceResponse: Codable {
        let ID: String
        let Version: ServiceVersionResponse
        let CreatedAt: Date
        let UpdatedAt: Date
        let Spec: ServiceSpecResponse
        
        struct ServiceVersionResponse: Codable {
            let Index: Int
        }
        
        struct ServiceSpecResponse: Codable {
            let Name: String
            let TaskTemplate: TaskTemplateResponse
            let UpdateConfig: DeployConfig?
            let RollbackConfig: DeployConfig?
        }
        
        enum ServiceRestartCondition: String, Codable {
            case any
            case none
            case onFailure = "on-failure"
        }
        
        struct ServiceRestartPolicy: Codable {
            /// Condition for restart.
            let Condition: ServiceRestartCondition
            /// Delay between restart attempts.
            let Delay: UInt64
            /// Maximum attempts to restart a given container before giving up (default value is 0, which is ignored).
            let MaxAttempts: UInt64
            /// Time window used to evaluate the restart policy (default value is 0, which is unbounded).
            let Window: UInt64
        }
        
        struct TaskTemplateResponse: Codable {
            let ContainerSpec: ContainerSpecResponse
            let RestartPolicy: ServiceRestartPolicy?
        }
        
        enum DeployFailureAction: String, Codable {
            case pause, `continue`
        }
        
        struct DeployConfig: Codable {
            let Parallelism: Int
            let Delay: UInt64
            let FailureAction: DeployFailureAction
            let Monitor: UInt64
            let MaxFailureRatio: Float
        }
        
        struct ContainerSpecResponse: Codable {
            let Image: String
        }
    }
}
