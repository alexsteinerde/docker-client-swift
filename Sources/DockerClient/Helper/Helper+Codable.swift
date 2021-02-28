import Foundation

extension Encodable {
    func encode(with encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        return try encoder.encode(self)
    }
}

extension Decodable {
    static func decode(with decoder: JSONDecoder = JSONDecoder(), from data: Data) throws -> Self {
        return try decoder.decode(Self.self, from: data)
    }
    
    static func decode(with decoder: JSONDecoder = JSONDecoder(), from string: String) throws -> Self {
        return try decoder.decode(Self.self, from: string.data(using: .utf8)!)
    }
}
