import NIO
import NIOHTTP1
import WebSocketKit
import Foundation

/// Attach to a container via Websocket
final class ContainerAttachEndpoint {
    typealias Body = NoBody
    typealias Response = ContainerAttach
    
    private var method: HTTPMethod = .GET
    private var path: String {
        "containers/\(nameOrId)/attach/ws"
    }

    private let dockerClient: DockerClient
    private let nameOrId: String
    private let stream: Bool
    private let logs: Bool
    private let detachKeys: String?
    /*private let stdin: Bool = true
    private let stdout: Bool
    private let stderr: Bool*/
    private var ws: WebSocket?

    private var query: String {
        """
        stream=\(stream)\
        &logs=\(logs)\
        \(detachKeys != nil ? "&detachKeys=\(detachKeys!)" : "")
        """
    }
    
    /*var query: String {
        """
        stdin=\(stdin)\
        &stdout=\(stdout)\
        &stderr=\(stderr)\
        &stream=\(stream)\
        &logs=\(logs)\
        \(detachKeys != nil ? "&detachKeys=\(detachKeys!)" : "")
        """
    }
    
    init(client: DockerClient, nameOrId: String, stream: Bool, stdin: Bool, stdout: Bool, stderr: Bool) {
        self.dockerClient = client
        self.nameOrId = nameOrId
        self.stream = stream
        self.stdin = stdin
        self.stdout = stdout
        self.stderr = stderr
    }*/
    
    init(client: DockerClient, nameOrId: String, stream: Bool, logs: Bool, detachKeys: String? = nil) {
        self.dockerClient = client
        self.nameOrId = nameOrId
        self.stream = stream
        self.logs = logs
        self.detachKeys = detachKeys
    }
    
    func connect() async throws -> ContainerAttach {
        let config = WebSocketClient.Configuration(tlsConfiguration: self.dockerClient.tlsConfig)
        
        let scheme = self.dockerClient.deamonURL.scheme
        guard scheme == "http" || scheme == "https" else {
            throw DockerError.unsupportedScheme("Attach only supports connecting to docker daemons via HTTP or HTTPS")
        }

        let output = AsyncThrowingStream<String, Error> { continuation in
            Task {
                try await WebSocket.connect(
                    scheme: scheme == "https" ? "wss" : "ws",
                    host: self.dockerClient.deamonURL.host ?? self.dockerClient.deamonURL.path,
                    port: self.dockerClient.deamonURL.port ?? (self.dockerClient.deamonURL.scheme == "https" ? 2376 : 2375),
                    path: "\(self.dockerClient.deamonURL.path)/\(self.dockerClient.apiVersion)/\(self.path)",
                    query: self.query,
                    headers: [:],
                    configuration: config,
                    on: self.dockerClient.client.eventLoopGroup
                ) { ws async in
                    
                    self.ws = ws
                    ws.onBinary { ws, buffer in
                        guard let rawData = String(data: Data(buffer: buffer), encoding: .utf8) else {
                            continuation.finish(throwing: DockerError.corruptedData("Could not decode Attach output as String"))
                            return
                        }
                        continuation.yield(rawData)
                    }
                }
            }
        }
        return ContainerAttach(attach: self, output: output)
    }
    
    func send(_ text: String) async throws {
        guard let ws = self.ws else {
            throw DockerError.notconnected
        }
        guard !ws.isClosed else {
            throw DockerError.notconnected
        }
        
        try await ws.send(text + "\n")
    }
}
