import NIOHTTP1

struct UpdateSwarmEndpoint: Endpoint {
    typealias Response = NoBody
    typealias Body = SwarmSpec
    var method: HTTPMethod = .POST
    
    var body: Body?
    private let version: UInt64
    private let rotateWorkerToken: Bool
    private let rotateManagerToken: Bool
    private let rotateManagerUnlockKey: Bool
    
    
    init(spec: SwarmSpec, version: UInt64, rotateWorkerToken: Bool, rotateManagerToken: Bool, rotateManagerUnlockKey: Bool) {
        self.version = version
        self.rotateWorkerToken = rotateWorkerToken
        self.rotateManagerToken = rotateManagerToken
        self.rotateManagerUnlockKey = rotateManagerUnlockKey
        self.body = spec
    }
    
    var path: String {
        "swarm/update?version=\(version)&rotateWorkerToken=\(rotateWorkerToken)&rotateManagerToken=\(rotateManagerToken)&rotateManagerUnlockKey=\(rotateManagerUnlockKey)"
    }
    
    //struct UpdateSwarmResponse: Codable {}
}
