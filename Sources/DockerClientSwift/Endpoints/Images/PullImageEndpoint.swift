import NIOHTTP1
import Foundation

struct PullImageEndpoint: PipelineEndpoint {
    typealias Body = NoBody
    typealias Response = PullImageResponse
    var method: HTTPMethod = .POST
    
    let imageName: String
    let credentials: RegistryAuth?
    
    var path: String {
        "images/create?fromImage=\(imageName)"
    }
    
    var headers: HTTPHeaders? = nil
    
    init(imageName: String, credentials: RegistryAuth?) {
        self.imageName = imageName
        self.credentials = credentials
        if let credentials = credentials, let token = credentials.token {
            self.headers = .init([("X-Registry-Auth", token)])
        }
    }
    
    struct PullImageResponse: Codable {
        let digest: String
    }
    
    struct Status: Codable {
        let status: String
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
