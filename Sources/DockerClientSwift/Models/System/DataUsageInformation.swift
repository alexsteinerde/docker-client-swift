import Foundation

/// Details about the Docker daemon data usage
public struct DataUsageInformation: Codable {
    public let layersSize: UInt64
    public let images: [ImageSummary]
    public let containers: [ContainerSummary]
    public let volumes: [Volume]
    //public let buildCache: [BuildCache]?
    public let builderSize: UInt64
    
    enum CodingKeys: String, CodingKey {
        case layersSize = "LayersSize"
        case images = "Images"
        case containers = "Containers"
        case volumes = "Volumes"
        //case buildCache = "BuildCache"
        case builderSize = "BuilderSize"
    }
}
