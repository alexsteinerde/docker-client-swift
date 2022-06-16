import NIOHTTP1
import NIO
import Foundation

struct BuildEndpoint: UploadEndpoint {
    var body: Body?
    
    typealias Response = AsyncThrowingStream<ByteBuffer, Error>
    typealias Body = ByteBuffer
    var method: HTTPMethod = .POST
    
    private let buildConfig: BuildConfig
    
    // Some Query String have to be encoded as JSON
    private let encoder: JSONEncoder
    private let decoder = JSONDecoder()
    
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
        let buildArgs = String(data: try! encoder.encode(buildConfig.buildargs), encoding: .utf8)
        let labels = String(data: try! encoder.encode(buildConfig.labels), encoding: .utf8)
        
        return
        """
        build\
        ?dockerfile=\(buildConfig.dockerfile)\
        \(tags)\
        \(buildConfig.extraHosts != nil ? "&extrahosts=\(buildConfig.extraHosts!)" : "")\
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
        &outputs=\(buildConfig.outputs ?? "")\
        &buildargs=\(buildArgs?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")\
        &labels=\(labels?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
        """
    }
    
    func map(response: Response) async throws -> AsyncThrowingStream<BuildStreamOutput, Error>  {
        return AsyncThrowingStream<BuildStreamOutput, Error> { continuation in
            Task {
                for try await var buffer in response {
                    let totalDataSize = buffer.readableBytes
                    while buffer.readerIndex < totalDataSize {
                        if buffer.readableBytes == 0 {
                            continuation.finish()
                        }
                        guard let data = buffer.readData(length: buffer.readableBytes) else {
                            continuation.finish(throwing: DockerLogDecodingError.dataCorrupted("Unable to read \(totalDataSize) bytes as Data"))
                            return
                        }
                        let splat = data.split(separator: 10 /* ascii code for \n */)
                        guard splat.count >= 1 else {
                            continuation.finish(throwing: DockerError.unknownResponse("Expected json terminated by line return"))
                            return
                        }
                        for streamItem in splat {                            
                            let model = try decoder.decode(BuildStreamOutput.self, from: streamItem)
                            guard model.message == nil else {
                                continuation.finish(throwing: DockerError.message(model.message!))
                                return
                            }
                            continuation.yield(model)
                        }
                    }
                }
                continuation.finish()
            }
        }
    }
}
