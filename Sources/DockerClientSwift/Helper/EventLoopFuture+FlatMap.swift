import NIO

extension EventLoopFuture {
    /// `flatMap` functions that accepts a throwing callback.
    /// - Parameters:
    ///   - callback: Throwing closure that returns and `EventLoopFuture` of the result type.
    /// - Returns: Returns an `EventLoopFuture` with the value of the callback future.
    @inlinable public func flatMap<NewValue>(file: StaticString = #file, line: UInt = #line, _ callback: @escaping (Value) throws -> EventLoopFuture<NewValue>) -> EventLoopFuture<NewValue> {
        self.flatMap { value in
            do {
                return try callback(value)
            } catch {
                return self.eventLoop.makeFailedFuture(error)
            }
        }
    }
}
