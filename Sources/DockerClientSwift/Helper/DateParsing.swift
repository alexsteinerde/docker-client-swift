import Foundation

extension Date {
    
    /// Some API results contain dates in a specific date format. It isn't ISO-8601 but a different one.
    /// - Parameter string: String of the date to parse.
    /// - Returns: Returns a `Date` instance if the string is in the correct format. Otherwise nil is returned. 
    /*static func parseDockerDate(_ string: String) -> Date? {
        let format = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSS'Z'"
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)
    }*/
}
