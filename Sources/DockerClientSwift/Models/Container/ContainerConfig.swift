import Foundation

public struct ContainerConfig: Codable {
    public var attachStderr: Bool = true
    
    public var attachStdin: Bool = false
    
    public var attachStdout: Bool = true
    
    /// Custom command to run, overrides the value of the Image if any
    public var command: [String]? = nil
    
    public var domainname: String = ""
    
    /// Custom entrypoint to run, overrides the value of the Image if any
    public var entrypoint: [String]? = nil
    
    /// A list of environment variables to set inside the container in the form `["VAR=value", ...].`
    /// A variable without `=` is removed from the environment, rather than to have an empty value.
    public var environmentVars: [String]? = nil
    
    /// An object mapping ports to an empty object in the form:
    /// `{"<port>/<tcp|udp|sctp>": {}}`
    public var exposedPorts: [String:EmptyObject]? = [:]
    
    /// A test to perform to periodically check that the container is healthy.
    public var healthcheck: HealthCheckConfig? = nil
    
    /// The hostname to use for the container, as a valid RFC 1123 hostname.
    public var hostname: String = ""
    
    /// The name (or reference) of the image to use
    public var image: String
    
    public var labels: [String:String]? = [:]
    
    public var macAddress: String?
    
    /// Whether networking is disabled for the container.
    public var networkDisabled: Bool?
    
    /// `ONBUILD` metadata that were defined in the image's `Dockerfile`
    public var onBuild: [String]? = nil
    
    public var openStdin: Bool = false
    
    /// Shell for when `RUN`, `CMD`, and `ENTRYPOINT` uses a shell.
    public var shell: [String]? = nil
    
    /// Close stdin after one attached client disconnects
    public var stdinOnce: Bool = false
    
    /// Unix signal to stop a container as a string or unsigned integer.
    public var stopSignal: StopSignal? = nil
    
    /// Timeout to stop a container, in seconds.
    /// After that, the container will be forcibly killed.
    public var stopTimeout: UInt? = 10
    
    /// Attach standard streams to a TTY, including stdin if it is not closed.
    public var tty: Bool = false
    
    /// The user that commands are run as inside the container.
    public var user: String = ""
    
    /// An object mapping mount point paths inside the container to empty objects.
    public var volumes: [String:EmptyObject]? = [:]
    
    /// The working directory for commands to run in.
    public var workingDir: String = ""
    
    enum CodingKeys: String, CodingKey {
        case attachStderr = "AttachStderr"
        case attachStdout = "AttachStdout"
        case attachStdin = "AttachStdin"
        case command = "Cmd"
        case domainname = "Domainname"
        case entrypoint = "Entrypoint"
        case environmentVars = "Env"
        case exposedPorts = "ExposedPorts"
        case healthcheck = "Healthcheck"
        case hostname = "Hostname"
        case image = "Image"
        case labels = "Labels"
        case macAddress = "MacAddress"
        case networkDisabled = "NetworkDisabled"
        case onBuild = "OnBuild"
        case openStdin = "OpenStdin"
        case shell = "Shell"
        case stdinOnce = "StdinOnce"
        case stopSignal = "StopSignal"
        case stopTimeout = "StopTimeout"
        case tty = "Tty"
        case user = "User"
        case volumes = "Volumes"
        case workingDir = "WorkingDir"
    }
    
    public enum StopSignal: String, Codable {
        case hup = "SIGHUP"
        case int = "SIGINT"
        case quit = "SIGQUIT"
        /// Illegal Instruction
        case ill = "SIGILL"
        case trap = "SIGTRAP"
        case abrt = "SIGABRT"
        case bus = "SIGBUS"
        case fpe = "SIGFPE"
        /// Kill signal. Immediately terminates the container without being forwarded to it.
        case kill = "SIGKILL"
        case usr1 = "SIGUSR1"
        case segv = "SIGSEGV"
        case usr2 = "SIGUSR2"
        case pipe = "SIGPIPE"
        case alrm = "SIGALRM"
        case term = "SIGTERM"
    }
    
    public struct HealthCheckConfig: Codable {
        /// The time to wait between checks, in nanoseconds.
        /// It should be 0 or at least 1000000 (1 ms). 0 means inherit.
        public var interval: UInt64
        
        /// The number of consecutive failures needed to consider a container as unhealthy. 0 means inherit.
        public var retries: UInt
        
        /// Start period for the container to initialize before starting health-retries countdown in nanoseconds.
        /// It should be 0 or at least 1000000 (1 ms). 0 means inherit.
        public var startPeriod: UInt64
        
        /// The test to perform. Possible values are
        /// - `[]` : inherit healthcheck from image or parent image)
        /// - `["NONE"]` : disable healthcheck
        /// - `["CMD", args...]` exec arguments directly
        /// - ["CMD-SHELL", command]` run command with system's default shell
        public var test: [String]
        
        /// The time to wait before considering the check to have hung. It should be 0 or at least 1000000 (1 ms). 0 means inherit.
        public var timeout: UInt64
        
        enum CodingKeys: String, CodingKey {
            case interval = "Interval"
            case retries = "Retries"
            case startPeriod = "StartPeriod"
            case test = "Test"
            case timeout = "Timeout"
        }
    }
    
    public struct EmptyObject: Codable {}
}
