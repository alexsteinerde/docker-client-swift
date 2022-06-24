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
    private let logs: Bool = true
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
        ?stdin=\(stdin)\
        &stdout=\(stdout)\
        &stderr=\(stderr)\
        &stream=\(stream)\
        &logs=\(logs)
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
    
    func connect() async throws {
        let config = WebSocketClient.Configuration(tlsConfiguration: self.dockerClient.tlsConfig)
        
        /*let endpoint = """
        \(self.dockerClient.deamonURL.scheme == "https" ? "wss" : "ws")://\
        \(self.dockerClient.deamonURL.host ?? self.dockerClient.deamonURL.path):\
        \(self.dockerClient.deamonURL.port ?? (self.dockerClient.deamonURL.scheme == "https" ? 2376 : 2375))\
        \(self.dockerClient.deamonURL.path)/\(self.dockerClient.apiVersion)/\(self.path)
        ?\(self.query)
        """
        try await WebSocket.connect(
            to: endpoint,
            headers: [:],
            configuration: config,
            on: elg
        ) { ws in
            self.ws = ws
        }*/
        print("\n••• SCHEME: \(self.dockerClient.deamonURL.scheme == "https" ? "wss" : "ws")")
        print("\n••• HOST: \(self.dockerClient.deamonURL.host ?? self.dockerClient.deamonURL.path)")
        print("\n••• PATH: \(self.dockerClient.deamonURL.path)/\(self.dockerClient.apiVersion)/\(self.path)")
        try await WebSocket.connect(
            scheme: self.dockerClient.deamonURL.scheme == "https" ? "wss" : "ws",
            host: self.dockerClient.deamonURL.host ?? self.dockerClient.deamonURL.path,
            port: self.dockerClient.deamonURL.port ?? (self.dockerClient.deamonURL.scheme == "https" ? 2376 : 2375),
            path: "\(self.dockerClient.deamonURL.path)/\(self.dockerClient.apiVersion)/\(self.path)",
            query: self.query,
            headers: [:],
            configuration: config,
            on: self.dockerClient.client.eventLoopGroup
        ) { ws async in
            print("\n••• CONNECTED?")
            self.ws = ws
            //try await ws.send("hello")
            ws.onBinary { ws, buffer in
                let rawData = String(data: Data(buffer: buffer), encoding: .utf8)
                print("\n••••••• BUFFER=\(rawData!) ")
            }
        }
        
    }
    
    func send(_ text: String) async throws {
        guard let ws = self.ws else {
            throw DockerError.message("Not connected")
        }
        
        try await ws.send(text)
        //try await ws.send(Array(text.utf8))
    }
    
}
