import NIOHTTP1

struct InspectContainerEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = ContainerResponse
    var method: HTTPMethod = .GET
    
    let nameOrId: String
    
    init(nameOrId: String) {
        self.nameOrId = nameOrId
    }
    
    var path: String {
        "containers/\(nameOrId)/json"
    }
    
    struct ContainerResponse: Codable {
        let Args: [String]
        let Config: ConfigResponse
        /// The time the container was created
        let Created: String
        let Driver: String
        let ExecIDs: [String]?
        let HostnamePath: String
        let HostsPath: String
        let Id: String
        let Image: String
        let LogPath: String
        let MountLabel: String
        let Name: String
        let Platform: String
        /// The path to the command being run
        let Path: String
        let ProcessLabel: String
        let ResolvConfPath: String
        let RestartCount: UInt64
        let State: StateResponse
        
        enum HealthStatus: String, Codable {
            case none, starting, healthy, unhealthy
        }
        
        struct HealthcheckResult: Codable {
            var Start: String
            var End: String
            var ExitCode: Int
            var Output: String
        }
        
        struct HealthResponse: Codable {
            let Status: HealthStatus
            /// FailingStreak is the number of consecutive failures
            let FailingStreak: UInt64
            let Log: [HealthcheckResult]
        }
        
        struct StateResponse: Codable {
            var Dead: Bool
            var Error: String
            /// The last exit code of this container
            var ExitCode: Int
            /// Health stores information about the container's healthcheck results.
            var Health: HealthResponse?
            /// The time when this container last exited.
            var FinishedAt: String
            /// Whether this container has been killed because it ran out of memory.
            var OOMKilled: Bool
            var Paused: Bool
            /// The process ID of this container
            var Pid: UInt64
            var Running: Bool
            var Restarting: Bool
            /// The time when this container was last started.
            var StartedAt: String
            var Status: String
        }
        
        struct ConfigResponse: Codable {
            let AttachStderr: Bool
            let AttachStdin: Bool
            let AttachStdout: Bool
            var Cmd: [String] = []
            let Domainname: String
            var Entrypoint: [String]? = []
            let Env: [String]
            let Hostname: String
            let Image: String
            var Labels: [String:String]? = [:]
            let OnBuild: [String]?
            let OpenStdin: Bool
            let StdinOnce: Bool
            let StopSignal: String?
            let Tty: Bool
            let User: String
            // let Volumes: ??? (optional/nullable)
            let WorkingDir: String
            
        }
    }
}
