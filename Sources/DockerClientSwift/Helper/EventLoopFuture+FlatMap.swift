import NIO

extension EventLoopFuture {
    @inlinable
    public func flatMap<NewValue>(file: StaticString = #file, line: UInt = #line, _ callback: @escaping (Value) throws -> EventLoopFuture<NewValue>) -> EventLoopFuture<NewValue> {
        self.flatMap { value in
            do {
                return try callback(value)
            } catch {
                return self.eventLoop.makeFailedFuture(error)
            }
        }
    }
}
