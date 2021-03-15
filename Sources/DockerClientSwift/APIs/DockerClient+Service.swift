import Foundation
import NIO

extension DockerClient {
    
    /// APIs related to images.
    public var services: ServicesAPI {
        .init(client: self)
    }
 
    public struct ServicesAPI {
        fileprivate var client: DockerClient
        
        public func list() throws -> EventLoopFuture<[Service]> {
            try client.run(ListServicesEndpoint())
                .map({ services in
                    services.map { service in
                        service.toService()
                    }
                })
        }
        
        public func update(service: Service, newImage: Image) throws -> EventLoopFuture<Service> {
            try client.run(UpdateServiceEndpoint(nameOrId: service.id.value, name: service.name, version: service.version, image: newImage.id.value))
                .flatMap({ _ in
                    try self.get(serviceByNameOrId: service.id.value)
                })
        }
        
        public func get(serviceByNameOrId nameOrId: String) throws -> EventLoopFuture<Service> {
            try client.run(InspectServiceEndpoint(nameOrId: nameOrId))
                .map { service in
                    service.toService()
                }
        }
        
        public func create(serviceName name: String, image: Image) throws -> EventLoopFuture<Service> {
            try client.run(CreateServiceEndpoint(name: name, image: image.id.value))
                .flatMap({ serviceId in
                    try client.run(InspectServiceEndpoint(nameOrId: serviceId.ID))
                })
                .map({ service in
                    service.toService()
                })
        }
    }
}

extension Service.ServiceResponse {
    func toService() -> Service {
        Service(id: .init(self.ID), name: self.Spec.Name, createdAt: Date.parseDockerDate(self.CreatedAt), updatedAt: Date.parseDockerDate(self.UpdatedAt), version: self.Version.Index, image: Image(id: Identifier(self.Spec.TaskTemplate.ContainerSpec.Image)))
    }
}
