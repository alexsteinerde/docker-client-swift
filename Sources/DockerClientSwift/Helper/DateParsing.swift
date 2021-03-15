import Foundation

extension Date {
    static func parseDockerDate(_ string: String) -> Date? {
        let format = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSS'Z'"
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)
    }
}
