import NIOHTTP1
import NIO
import Foundation

struct BuildEndpoint: Endpoint {
    var body: Body?
    
    typealias Response = NoBody
    typealias Body = Data
    var method: HTTPMethod = .POST
    
    private let buildConfig: BuildConfig
    
    private let encoder: JSONEncoder
    
    init(buildConfig: BuildConfig) {
        self.buildConfig = buildConfig
        self.encoder = .init()
    }
    
    var path: String {
        var tags = ""
        for rt in self.buildConfig.repoTags ?? [] {
            tags += "&t=\(rt)"
        }
        
        let cacheFrom = try? encoder.encode(buildConfig.cacheFrom)
        let buildArgs = try? encoder.encode(buildConfig.buildargs)
        let labels = try? encoder.encode(buildConfig.labels)
        
        return
        """
        build\
        ?dockerfile=\(buildConfig.dockerfile)\
        \(tags)\
        &extrahosts=\(buildConfig.extraHosts ?? "")\
        &remote=\(buildConfig.remote?.absoluteString ?? "")\
        &q=\(buildConfig.quiet)
        &nocache=\(buildConfig.noCache)\
        &cachefrom=\(String(data: cacheFrom ?? Data(), encoding: .utf8) ?? "")\
        &pull=\(buildConfig.pull)\
        &rm=\(buildConfig.rm)
        &forcerm=\(buildConfig.forceRm)\
        &memory=\(buildConfig.memory)\
        &memswap=\(buildConfig.memorySwap)\
        &cpushares=\(buildConfig.cpuShares)\
        &cpusetcpus=\(buildConfig.cpusetCpus ?? "")\
        &cpuperiod=\(buildConfig.cpuPeriod)\
        &cpuquota=\(buildConfig.cpuQuota)\
        &buildargs=\(String(data: buildArgs ?? Data(), encoding: .utf8) ?? "")\
        &shmsize=\(buildConfig.shmSizeBytes?.description ?? "")\
        &squash=\(buildConfig.squash)\
        &labels=\(String(data: labels ?? Data(), encoding: .utf8) ?? "")\
        &networkmode=\(buildConfig.networkMode ?? "")\
        &platform=\(buildConfig.platform ?? "")\
        &target=\(buildConfig.target ?? "")\
        &outputs=\(buildConfig.outputs ?? "")
        """
    }
}
