import NIO
import NIOHTTP1
import WebSocketKit
import Foundation

class ContainerAttachEndpoint {
    typealias Body = NoBody
    typealias Response = AsyncThrowingStream<ByteBuffer, Error>
    
    var method: HTTPMethod = .GET
    
    private let dockerClient: DockerClient
    private let nameOrId: String
    private let stream: Bool
    private let stdin: Bool
    private let stdout: Bool
    private let stderr: Bool
    private var ws: WebSocket?

    var path: String {
        """
        containers/\(nameOrId)/attach/ws
        """
    }

    var query: String {
        """
        stdin=\(stdin)\
        &stdout=\(stdout)\
        &stderr=\(stderr)\
        &stream=\(stream)
        """
    }
    
    init(client: DockerClient, nameOrId: String, stream: Bool, stdin: Bool, stdout: Bool, stderr: Bool) {
        self.dockerClient = client
        self.nameOrId = nameOrId
        self.stream = stream
        self.stdin = stdin
        self.stdout = stdout
        self.stderr = stderr
    }
    
    func connect(elg: EventLoopGroup) async throws {
        let config = WebSocketClient.Configuration.init(tlsConfiguration: self.dockerClient.tlsConfig)
        WebSocket.connect(
            scheme: self.dockerClient.deamonURL.scheme == "https" ? "wss" : "ws",
            host: self.dockerClient.deamonURL.host ?? self.dockerClient.deamonURL.path,
            port: self.dockerClient.deamonURL.port ?? (self.dockerClient.deamonURL.scheme == "https" ? 2376 : 2375),
            path: "\(self.dockerClient.deamonURL.path)/\(self.dockerClient.apiVersion)/\(self.path)",
            query: self.query,
            headers: [:],
            configuration: config,
            on: elg
        ) { ws in
            self.ws = ws
        }
        
    }
    
}
