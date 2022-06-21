import Foundation
import BetterCodable

// MARK: - ContainerStats
public struct ContainerStats: Codable {
    /// Date and time when the statistics were read
    @DateValue<WeirdDockerStrategy>
    private(set) public var readAt: Date
    
    @DateValue<WeirdDockerStrategy>
    private(set) public var previousReadAt: Date
    
    /// Number of processes
    public let pids: PidStats
    
    /// Networking stats
    public let networks: [String:NetworkStats]
    
    public let memory: MemoryStats
    
    /// Block devices stats
    public let io: BlkioStats?
    
    /// CPU stats
    public let cpu: CpuStats
    
    /// CPU statistics of the _previous_ read
    public let previousCpu: CpuStats
    
    enum CodingKeys: String, CodingKey {
        case readAt = "read"
        case previousReadAt = "preread"
        case pids = "pids_stats"
        case networks = "networks"
        case memory = "memory_stats"
        case cpu = "cpu_stats"
        case previousCpu = "precpu_stats"
        case io = "blkio_stats"
    }
    
    // MARK: - PidStats
    public struct PidStats: Codable {
        /// Number of processes running in the container.
        public let current: Int
    }
    
    // MARK: - NetworkStats
    public struct NetworkStats: Codable {
        public let rxBytes: UInt64
        public let rxDropped: UInt64
        public let rxErrors: UInt64
        public let rxPackets: UInt64
        public let txBytes: UInt64
        public let txDropped: UInt64
        public let txErrors: UInt64
        public let txPackets: UInt64
        
        enum CodingKeys: String, CodingKey {
            case rxBytes = "rx_bytes"
            case rxDropped = "rx_dropped"
            case rxErrors = "rx_errors"
            case rxPackets =  "rx_packets"
            case txBytes = "tx_bytes"
            case txDropped = "tx_dropped"
            case txErrors = "tx_errors"
            case txPackets = "tx_packets"
        }
    }
    
    // MARK: - MemoryStats
    public struct MemoryStats: Codable {
        /// Maximum usage ever recorded.
        /// Is not set when using cgroup v2.
        public let maxUsage: UInt64?
        
        public let usage : UInt64
        
        /// Number of times memory usage hits limits.
        /// Is not set when using cgroup v2.
        public let failCount: UInt64?
        
        public let limit: UInt64
        
        /// All the stats exported via `memory.stat`.
        /// is not set when using cgroup v1.
        public let stats: [String:UInt64]?
        
        enum CodingKeys: String, CodingKey {
            case maxUsage = "max_usage"
            case usage = "usage"
            case failCount = "failcnt"
            case limit = "limit"
            case stats = "stats"
        }
        
        // fields from official Docker doc do not map reality with a recent Docker (cgroupv2?)
        /*public struct Stats: Codable {
            /// The page cache memory usage, in bytes
            public let cache: UInt64?
            
            /// The amount of memory that doesn’t correspond to anything on disk: stacks, heaps, transparent hugepages, and anonymous memory maps, in bytes.
            public let rss: UInt64?
            
            /// The swap usage, in bytes.
            public let swap: UInt64?
            
            /// The data waiting to get written back to the disk, in bytes
            public let dirty: UInt64?
            
            /// The data queued for syncing to disk, in bytes.
            public let writeback: UInt64?
            
        }*/
    }
    
    // MARK: - CpuStats
    public struct CpuStats: Codable {

        public let cpuUsage: CpuUsage
        
        public let systemCpuUsage: UInt64?
        
        /// Online CPUs
        public let cpus: UInt16?
        
        public let throttling: CpuThrottling
        
        enum CodingKeys: String, CodingKey {
            case cpuUsage = "cpu_usage"
            case systemCpuUsage = "system_cpu_usage"
            case cpus = "online_cpus"
            case throttling = "throttling_data"
        }
        
        public struct CpuUsage: Codable {
            /// Total CPU time consumed per core, in nanoseconds.
            /// Is not set when using cgroup v2.
            public let perCpu: [UInt64]?
            
            /// The amount of time a process has direct control of the CPU, executing process code, in nanoseconds.
            public let userMode: UInt64
            
            /// The time the kernel is executing system calls on behalf of the process, in nanoseconds.
            public let kernelMode: UInt64
            
            /// Total CPU time consumed, in nanoseconds.
            public let total: UInt64
            
            enum CodingKeys: String, CodingKey {
                case perCpu = "percpu_usage"
                case userMode = "usage_in_usermode"
                case kernelMode = "usage_in_kernelmode"
                case total = "total_usage"
            }
        }
        
        public struct CpuThrottling: Codable {
            /// Number of periods with throttling active.
            public let periods: UInt64
            
            /// Number of periods when the container hit its throttling limit.
            public let throttledPeriods: UInt64
            
            /// Aggregate time the container was throttled for, in nanoseconds.
            public let throttledTime: UInt64
            
            enum CodingKeys: String, CodingKey {
                case periods = "periods"
                case throttledPeriods = "throttled_periods"
                case throttledTime = "throttled_time"
            }
        }
    }
    
    // MARK: - BlkioStats
    public struct BlkioStats: Codable {
        public let serviceBytesRecursive: [BlkioStatEntry]
        public let servicedRecursive: [BlkioStatEntry]?
        public let queuedRecursive: [BlkioStatEntry]?
        public let serviceTimeRecursive: [BlkioStatEntry]?
        public let waitTimeRecursive: [BlkioStatEntry]?
        public let mergedRecursive: [BlkioStatEntry]?
        public let timeRecursive: [BlkioStatEntry]?
        public let sectorsRecursive: [BlkioStatEntry]?
        
        enum CodingKeys: String, CodingKey {
            case serviceBytesRecursive = "io_service_bytes_recursive"
            case servicedRecursive = "io_serviced_recursive"
            case queuedRecursive = "io_queue_recursive"
            case serviceTimeRecursive = "io_service_time_recursive"
            case waitTimeRecursive = "io_wait_time_recursive"
            case mergedRecursive = "io_merged_recursive"
            case timeRecursive = "io_time_recursive"
            case sectorsRecursive = "sectors_recursive"
        }
        
        public struct BlkioStatEntry: Codable {
            public let major: UInt64
            public let minor: UInt64
            public let op: String //BlkioOperation
            public let value: UInt64
            
            // Not usable. Returns value with uppercase first letter on Linux, lowercase on mac.
            public enum BlkioOperation: String, Codable {
                case read = "Read"
                case write = "Write"
                case sync = "Sync"
                case async = "Async"
                case discard = "Discard"
                case total = "Total"
            }
        }
    }
}
