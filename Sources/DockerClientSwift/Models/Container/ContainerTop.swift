import Foundation

public struct ContainerTop: Codable {
    /// The `ps` column titles
    public let titles: [String]
    
    /// Processes running in the container, where each item is an array of values corresponding to the titles.
    public let processes: [[String]]
    
    enum CodingKeys: String, CodingKey {
        case titles = "Titles"
        case processes = "Processes"
    }
}
