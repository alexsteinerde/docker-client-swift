import NIO
import NIOHTTP1
import Foundation

final class GetContainerStatsEndpoint: JSONStreamingEndpoint<ContainerStats> {
    typealias Body = NoBody
    typealias Response = AsyncThrowingStream<ContainerStats, Error>
    
    private let nameOrId: String
    private let stream: Bool
    private let oneShot: Bool
    
    init(nameOrId: String, stream: Bool, oneShot: Bool) {
        
        self.nameOrId = nameOrId
        self.stream = stream
        self.oneShot = oneShot
        super.init(path: "containers/\(nameOrId)/stats?stream=\(stream)&one-shot=\(oneShot)", method: .GET)
    }
}
