import Foundation

public struct ServiceSpec: Codable {
    public var name: String
    public var labels: [String:String] = [:]
    public var taskTemplate: TaskTemplate
    public var mode: Mode
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case labels = "Labels"
        case taskTemplate = "TaskTemplate"
        case mode = "Mode"
    }
    
    public struct TaskTemplate: Codable {
        public var containerSpec: ContainerSpec
        public var forceUpdate: UInt
        public var runtime: String = ""
        
        enum CodingKeys: String, CodingKey {
            case containerSpec = "ContainerSpec"
            case forceUpdate = "ForceUpdate"
            case runtime = "Runtime"
        }
    }
    
    public struct Mode: Codable {
        
    }
    
    public struct ContainerSpec: Codable {
        public var image: String
        
        public var isolation: String
        
        public var labels: [String:String]? = [:]
        
        public var command: [String]? = []
        
        public var args: [String]? = []
        
        public var tty: Bool? = false
        
        enum CodingKeys: String, CodingKey {
            case image = "Image"
            case isolation = "Isolation"
            case labels = "Labels"
            case args = "Args"
            case tty = "TTY"
        }
    }
}
