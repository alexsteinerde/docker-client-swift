import NIOHTTP1
import NIO
import Foundation

struct BuildEndpoint: UploadEndpoint {
    var body: Body?
    
    typealias Response = NoBody
    typealias Body = ByteBuffer
    var method: HTTPMethod = .POST
    
    private let buildConfig: BuildConfig
    
    // Some Query String have to be encoded as JSON
    private let encoder: JSONEncoder
    
    init(buildConfig: BuildConfig, context: ByteBuffer) {
        self.buildConfig = buildConfig
        self.body = context
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
        &q=\(buildConfig.quiet)\
        &nocache=\(buildConfig.noCache)\
        &cachefrom=\(String(data: cacheFrom ?? Data(), encoding: .utf8) ?? "")\
        &pull=\(buildConfig.pull)\
        &rm=\(buildConfig.rm)\
        &forcerm=\(buildConfig.forceRm)\
        &memory=\(buildConfig.memory)\
        &memswap=\(buildConfig.memorySwap)\
        &cpushares=\(buildConfig.cpuShares)\
        &cpusetcpus=\(buildConfig.cpusetCpus ?? "")\
        &cpuperiod=\(buildConfig.cpuPeriod)\
        &cpuquota=\(buildConfig.cpuQuota)\
        &shmsize=\(buildConfig.shmSizeBytes?.description ?? "")\
        &squash=\(buildConfig.squash)\
        &networkmode=\(buildConfig.networkMode ?? "")\
        &platform=\(buildConfig.platform ?? "")\
        &target=\(buildConfig.target ?? "")\
        &outputs=\(buildConfig.outputs ?? "")
        """
        //         &labels=\(String(data: labels ?? Data(), encoding: .utf8) ?? "")\
        //        &buildargs=\(String(data: buildArgs ?? Data(), encoding: .utf8) ?? "")\


    }
}
