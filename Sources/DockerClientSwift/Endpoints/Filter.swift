import Foundation

/// Docker API queries filters parameters
protocol DockerFilterProtocol: Codable {}

extension DockerFilterProtocol {
    // // TODO: implement crappy Docker encoding (`{"name":{"myname":true}}`)
    func encodeForRequest() throws -> String? {
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(self)
        return String(data: encoded, encoding: .utf8)!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}
