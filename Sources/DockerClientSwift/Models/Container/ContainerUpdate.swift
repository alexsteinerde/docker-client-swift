import Foundation

public struct ContainerUpdate: Codable {
    /// Block IO weight (relative weight).
    /// Allowed values range: [ 0 .. 1000 ]
    public var blkioWeight: UInt16? = nil
    
    /// Block IO weight (relative device weight)
    public var blkioWeightDevice: [ContainerHostConfig.BlkioWeight]? = nil
    
    /// Limit read rate (bytes per second) from a device
    public var blkioDeviceReadBps: ContainerHostConfig.BlkioRateLimit? = nil
    
    /// Limit write rate (bytes per second) to a device
    public var blkioDeviceWriteBps: ContainerHostConfig.BlkioRateLimit? = nil
    
    /// Limit read rate (IO per second) from a device
    public var blkioDeviceReadIOps: ContainerHostConfig.BlkioRateLimit? = nil
    
    /// Limit write rate (IO per second) to a device
    public var blkioDeviceWriteIOps: ContainerHostConfig.BlkioRateLimit? = nil
    
    /// Path to cgroups under which the container's cgroup is created.
    /// If the path is not absolute, the path is considered to be relative to the cgroups path of the init process.
    /// Cgroups are created if they do not already exist.
    public var cgroupParent: String? = nil
    
    // Windows only
    // public let ConsoleSize: [UInt8]
    
    /// Windows only
    /// The number of usable CPUs (Windows only).
    /// On Windows Server containers, the processor resource controls are mutually exclusive. The order of precedence is `CPUCount` first, then `CPUShares`, and `CPUPercent` last.
    public var cpuCount: UInt8? = nil
    
    /// Windows only
    public var cpuPercent: UInt8? = nil
    
    /// The length of a CPU period in microseconds.
    public var cpuPeriod: UInt64? = nil
    
    /// Microseconds of CPU time that the container can get in a CPU period.
    public var cpuQuota: UInt64? = nil
    
    /// The length of a CPU real-time period, in microseconds.
    /// Set to 0 to allocate no time allocated to real-time tasks.
    public var cpuRealtimePeriod: UInt64? = nil
    
    /// The length of a CPU real-time runtime, in microseconds.
    /// Set to 0 to allocate no time allocated to real-time tasks.
    public var cpuRealtimeRuntime: UInt64? = nil
    
    /// CPUs in which to allow execution (e.g., `0-3`, `0,1`).
    public var cpusetCpus: String? = nil
    
    /// Memory nodes (MEMs) in which to allow execution (`0-3`, `0,1`). Only effective on NUMA systems.
    public var cpusetMems: String? = nil
    
    /// Value representing this container's relative CPU weight versus other containers.
    public var cpuShares: UInt? = nil
    
    public var devices: [ContainerHostConfig.DeviceMapping]? = nil
    
    /// A list of cgroup rules to apply to the container
    public var deviceCgroupRules: [String]? = nil
    
    // TODO: implement
    // public var deviceRequests
    
    /// Run an init inside the container that forwards signals and reaps processes.
    /// This field is omitted if empty, and the default (as configured on the daemon) is used.
    public var `init`: Bool? = nil
    
    /// Kernel memory limit in bytes.
    /// **Deprecated**: This field is deprecated as the kernel 5.4 deprecated `kmem.limit_in_bytes`.
    @available(*, deprecated)
    public var kernelMemory: UInt64? = nil
    
    /// Hard limit for kernel TCP buffer memory (in bytes).
    public var kernelMemoryTcp: UInt64? = nil
    
    /// Memory limit in bytes.
    public var memoryLimit: UInt64? = nil
    
    /// Memory soft limit in bytes.
    public var memoryReservation: UInt64? = nil
    
    /// Total memory limit (memory + swap). Set as -1 to enable unlimited swap.
    public var memorySwap: UInt64? = nil
    
    /// Tune a container's memory swappiness behavior. Accepts an integer between 0 and 100.
    public var memorySwappiness: Int8? = nil
    
    /// CPU quota in units of 10^-9 CPUs.
    public var nanoCpus: UInt64? = nil
    
    /// Disable OOM Killer for the container.
    public var oomKillDisable: Bool? = nil
    
    /// Tune a container's PIDs limit. Set `0` or `-1` for unlimited, or `null to not change.
    public var pidsLimit: UInt64? = nil
    
    /// A list of resource limits to set in the container
    public var ulimits: [ContainerHostConfig.Ulimit]? = nil
    
    public var restartPolicy: ContainerHostConfig.RestartPolicy? = nil
        
    public init(blkioWeight: UInt16? = nil, blkioWeightDevice: [ContainerHostConfig.BlkioWeight]? = nil, blkioDeviceReadBps: ContainerHostConfig.BlkioRateLimit? = nil, blkioDeviceWriteBps: ContainerHostConfig.BlkioRateLimit? = nil, blkioDeviceReadIOps: ContainerHostConfig.BlkioRateLimit? = nil, blkioDeviceWriteIOps: ContainerHostConfig.BlkioRateLimit? = nil, cgroupParent: String? = nil, cpuCount: UInt8? = nil, cpuPercent: UInt8? = nil, cpuPeriod: UInt64? = nil, cpuQuota: UInt64? = nil, cpuRealtimePeriod: UInt64? = nil, cpuRealtimeRuntime: UInt64? = nil, cpusetCpus: String? = nil, cpusetMems: String? = nil, cpuShares: UInt? = nil, devices: [ContainerHostConfig.DeviceMapping]? = nil, deviceCgroupRules: [String]? = nil, init: Bool? = nil, kernelMemory: UInt64? = nil, kernelMemoryTcp: UInt64? = nil, memoryLimit: UInt64? = nil, memoryReservation: UInt64? = nil, memorySwap: UInt64? = nil, memorySwappiness: Int8? = nil, nanoCpus: UInt64? = nil, oomKillDisable: Bool? = nil, pidsLimit: UInt64? = nil, restartPolicy: ContainerHostConfig.RestartPolicy? = nil, ulimits: [ContainerHostConfig.Ulimit]? = nil) {
        self.blkioWeight = blkioWeight
        self.blkioWeightDevice = blkioWeightDevice
        self.blkioDeviceReadBps = blkioDeviceReadBps
        self.blkioDeviceWriteBps = blkioDeviceWriteBps
        self.blkioDeviceReadIOps = blkioDeviceReadIOps
        self.blkioDeviceWriteIOps = blkioDeviceWriteIOps
        self.cgroupParent = cgroupParent
        self.cpuCount = cpuCount
        self.cpuPercent = cpuPercent
        self.cpuPeriod = cpuPeriod
        self.cpuQuota = cpuQuota
        self.cpuRealtimePeriod = cpuRealtimePeriod
        self.cpuRealtimeRuntime = cpuRealtimeRuntime
        self.cpusetCpus = cpusetCpus
        self.cpusetMems = cpusetMems
        self.cpuShares = cpuShares
        self.devices = devices
        self.deviceCgroupRules = deviceCgroupRules
        self.`init` = `init`
        self.kernelMemory = kernelMemory
        self.kernelMemoryTcp = kernelMemoryTcp
        self.memoryLimit = memoryLimit
        self.memoryReservation = memoryReservation
        self.memorySwap = memorySwap
        self.memorySwappiness = memorySwappiness
        self.nanoCpus = nanoCpus
        self.oomKillDisable = oomKillDisable
        self.pidsLimit = pidsLimit
        self.restartPolicy = restartPolicy
        self.ulimits = ulimits
    }
    
    enum CodingKeys: String, CodingKey {
        case blkioWeight = "BlkioWeight"
        case blkioWeightDevice = "BlkioWeightDevice"
        case blkioDeviceReadBps = "BlkioDeviceReadBps"
        case blkioDeviceWriteBps = "BlkioDeviceWriteBps"
        case blkioDeviceReadIOps = "BlkioDeviceReadIOps"
        case blkioDeviceWriteIOps = "BlkioDeviceWriteIOps"
        case cgroupParent = "CgroupParent"
        case cpuCount = "CpuCount"
        case cpuPercent = "CpuPercent"
        case cpuPeriod = "CpuPeriod"
        case cpuQuota = "CpuQuota"
        case cpuRealtimePeriod = "CpuRealtimePeriod"
        case cpuRealtimeRuntime = "CpuRealtimeRuntime"
        case cpusetCpus = "CpusetCpus"
        case cpuShares = "CpuShares"
        case devices = "Devices"
        case deviceCgroupRules = "DeviceCgroupRules"
        case `init` = "Init"
        case kernelMemory = "KernelMemory"
        case kernelMemoryTcp = "KernelMemoryTCP"
        case memoryLimit = "Memory"
        case memoryReservation = "MemoryReservation"
        case memorySwap = "MemorySwap"
        case memorySwappiness = "MemorySwappiness"
        case nanoCpus = "NanoCpus"
        case oomKillDisable = "OomKillDisable"
        case pidsLimit = "PidsLimit"
        case restartPolicy = "RestartPolicy"
        case ulimits = "Ulimits"
    }
}
