import Foundation

public enum DockerError: Error {
    /// Not connected to an Attach/Exec endpoint, or disconnected
    case notconnected
    /// Custom error from the Docker daemon
    case message(String)
    case unknownResponse(String)
    case corruptedData(String)
    case errorCode(Int, String?)
    case unsupportedScheme(String)
}
