import Foundation
import BetterCodable

/// the inconsistent date format used by Docker for containers, images and Version Buildtime
/// when set, format is "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSS'Z'"
/// when not set, docker returns "0001-01-01T00:00:00Z"
public struct WeirdDockerStrategy: DateValueCodableStrategy {
    
    private static let formatter: DateFormatter = {
        let format = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSS'Z'"
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter
    }()
    
    public static func decode(_ value: String) throws -> Date {
        if let date = formatter.date(from: value) {
            return date
        }
        else if let date = ISO8601DateFormatter().date(from: value) {
            return date
        }
        else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid Date Format!"))
        }
    }
    
    public static func encode(_ date: Date) -> String {
        return formatter.string(from: date)
    }
}
