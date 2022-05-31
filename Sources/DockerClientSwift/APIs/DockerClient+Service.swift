import Foundation
import NIO

extension DockerClient {
    
    /// APIs related to images.
    public var services: ServicesAPI {
        .init(client: self)
    }
 
    public struct ServicesAPI {
        fileprivate var client: DockerClient
        
        /// Lists all services running in the Docker instance.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns a list of `Service` instances.
        public func list() async throws -> [Service] {
            try await client.run(ListServicesEndpoint())
                .map({ service in
                        service.toService()
                })
        }
        
        /// Updates a service with a new image.
        /// - Parameters:
        ///   - service: Instance of a `Service` that should be updated.
        ///   - newImage: Instance of an `Image` that should be used as the new image for the service.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns the updated `Service`.
        public func update(service: Service, newImage: Image) async throws -> Service {
            try await client.run(UpdateServiceEndpoint(nameOrId: service.id.value, name: service.name, version: service.version, image: newImage.id.value))
            return try await self.get(serviceByNameOrId: service.id.value)
        }
        
        /// Gets a service by a given name or id.
        /// - Parameter nameOrId: Name or id of a service that should be fetched.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Return the `Service`.
        public func get(serviceByNameOrId nameOrId: String) async throws -> Service {
            let service = try await client.run(InspectServiceEndpoint(nameOrId: nameOrId))
            return service.toService()
        }
        
        /// Created a new service with a name and an image.
        /// This is the minimal way of creating a new service.
        /// - Parameters:
        ///   - name: Name of the new service.
        ///   - image: Instance of an `Image` for the service.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns the newly created `Service`.
        public func create(serviceName name: String, image: Image) async throws -> Service {
            let serviceId = try await client.run(CreateServiceEndpoint(name: name, image: image.id.value))
            let service = try await client.run(InspectServiceEndpoint(nameOrId: serviceId.ID))
            return service.toService()
        }
    }
}

extension Service.ServiceResponse {
    
    /// Internal function that converts the response from Docker to the DockerClient representation.
    /// - Returns: Returns an instance of `Service` with the values of the current response.
    internal func toService() -> Service {
        Service(
            id: .init(self.ID),
            name: self.Spec.Name,
            createdAt: Date.parseDockerDate(self.CreatedAt),
            updatedAt: Date.parseDockerDate(self.UpdatedAt),
            version: self.Version.Index,
            image: Image(id: Identifier(self.Spec.TaskTemplate.ContainerSpec.Image))
        )
    }
}
