import Foundation
import NIO
import WebSocketKit


/// Gives access to the output and the standard input of an attached container.
public final class ContainerAttach {
    public let output: AsyncThrowingStream<String, Error>
    
    private let attachEndpoint: ContainerAttachEndpoint
    
    public func send(_ text: String) async throws {
        try await self.attachEndpoint.send(text)
    }
    
    internal init(attach: ContainerAttachEndpoint, output: AsyncThrowingStream<String, Error>) {
        self.attachEndpoint = attach
        self.output = output
    }
}
