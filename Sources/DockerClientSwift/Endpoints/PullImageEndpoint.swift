import NIOHTTP1

struct PullImageEndpoint: PipelineEndpoint {
    typealias Body = NoBody
    
    let imageName: String
    
    var method: HTTPMethod = .POST
    var path: String {
        "images/create?fromImage=\(imageName)"
    }
    
    typealias Response = PullImageResponse
    
    struct PullImageResponse: Codable {
        let digest: String
    }
    
    func map(data: String) throws -> PullImageResponse {
        if let message = try? MessageResponse.decode(from: data) {
            throw DockerError.message(message.message)
        }
        let parts = data.components(separatedBy: "\r\n")
            .filter({ $0.count > 0 })
            .compactMap({ try? Status.decode(from: $0) })
        if let digest = parts.last(where: { $0.status.hasPrefix("Digest:")})
            .map({ (status) -> String in
                status.status.replacingOccurrences(of: "Digest: ", with: "")
            }) {
            return .init(digest: digest)
        } else {
            throw DockerError.unknownResponse(data)
        }
    }
}
