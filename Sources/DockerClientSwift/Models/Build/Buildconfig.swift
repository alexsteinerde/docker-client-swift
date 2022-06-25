import Foundation

/// Configuration for a `docker build`.
public struct BuildConfig: Codable {
    /// Path within the build context to the Dockerfile. This is ignored if `remote` is specified and points to an external Dockerfile.
    public var dockerfile: String = "Dockerfile"
    
    /// list of names and optional tags to apply to the image, in the `name:tag` format.
    /// If you omit the tag the default `latest` value is assumed.
    public var repoTags: [String]? = []
    
    /// Extra hosts to add to /etc/hosts
    public var extraHosts: String? = nil
    
    /// A Git repository URI or HTTP/HTTPS context URI.
    /// If the URI points to a single text file, the file’s contents are placed into a file called Dockerfile and the image is built from that file.
    /// If the URI points to a tarball, the file is downloaded by the daemon and the contents therein used as the context for the build.
    /// If the URI points to a tarball and the dockerfile parameter is also specified, there must be a file with the corresponding path inside the tarball.
    public var remote: URL? = nil
    
    /// Suppress verbose build output.
    public var quiet: Bool = false
    
    /// Do not use the cache when building the image.
    public var noCache: Bool = false
    
    /// List of images used for build cache resolution.
    public var cacheFrom: [String] = []
    
    /// Attempt to pull the image even if an older image exists locally.
    public var pull: Bool = false
    
    /// Remove intermediate containers after a successful build.
    public var rm: Bool = true
    
    /// Always remove intermediate containers, even upon failure.
    public var forceRm: Bool = false
    
    /// Set memory limit for build.
    public var memory: UInt64 = 0
    
    /// Total memory (memory + swap). Set as -1 to disable swap.
    public var memorySwap: Int64 = -1
    
    /// CPU shares (relative weight).
    public var cpuShares: UInt64 = 0
    
    /// CPUs in which to allow execution (e.g., `0-3`, `0,1`).
    public var cpusetCpus: String? = nil
    
    /// The length of a CPU period in microseconds.
    public var cpuPeriod: UInt64 = 0
    
    /// Microseconds of CPU time that the container can get in a CPU period.
    public var cpuQuota: UInt64 = 0
    
    /// String pairs for build-time variables.
    /// Users pass these values at build-time. Docker uses the buildargs as the environment context for commands run via the Dockerfile `RUN` instruction, or for variable expansion in other Dockerfile instructions.
    /// This is not meant for passing secret values.
    public var buildArgs: [String:String] = [:]
    
    /// Size of `/dev/shm` in bytes.
    /// The size must be greater than 0. If omitted the system uses 64MB.
    public var shmSizeBytes: UInt64? = nil
    
    /// Squash the resulting images layers into a single layer. (Experimental release only.)
    public var squash: Bool = false
    
    /// Arbitrary key/value labels to set on the image
    public var labels: [String:String] = [:]
        
    /// Sets the networking mode for the run commands during build.
    /// Supported standard values are: `bridge`, `host`, `none`, and `container:<name|id>`.
    /// Any other value is taken as a custom network's name or ID to which this container should connect to.
    public var networkMode: String?
    
    /// Platform in the format os[/arch[/variant]]
    public var platform: String? = nil
    
    /// Target build stage
    public var target: String? = nil
    
    /// BuildKit output configuration
    public var outputs: String? = nil
    
    public init(dockerfile: String = "Dockerfile", repoTags: [String]? = [], extraHosts: String? = nil, remote: URL? = nil, quiet: Bool = false, noCache: Bool = false, cacheFrom: [String] = [], pull: Bool = false, rm: Bool = true, forceRm: Bool = false, memory: UInt64 = 0, memorySwap: Int64 = -1, cpuShares: UInt64 = 0, cpusetCpus: String? = nil, cpuPeriod: UInt64 = 0, cpuQuota: UInt64 = 0, buildArgs: [String : String] = [:], shmSizeBytes: UInt64? = nil, squash: Bool = false, labels: [String : String] = [:], networkMode: String? = nil, platform: String? = nil, target: String? = nil, outputs: String? = nil) {
        self.dockerfile = dockerfile
        self.repoTags = repoTags
        self.extraHosts = extraHosts
        self.remote = remote
        self.quiet = quiet
        self.noCache = noCache
        self.cacheFrom = cacheFrom
        self.pull = pull
        self.rm = rm
        self.forceRm = forceRm
        self.memory = memory
        self.memorySwap = memorySwap
        self.cpuShares = cpuShares
        self.cpusetCpus = cpusetCpus
        self.cpuPeriod = cpuPeriod
        self.cpuQuota = cpuQuota
        self.buildArgs = buildArgs
        self.shmSizeBytes = shmSizeBytes
        self.squash = squash
        self.labels = labels
        self.networkMode = networkMode
        self.platform = platform
        self.target = target
        self.outputs = outputs
    }
}
