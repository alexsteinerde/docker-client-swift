import Foundation

extension DockerClient {
    
    /// APIs related to Docker plugins.
    public var plugins: PluginsAPI {
        .init(client: self)
    }
    
    public struct PluginsAPI {
        fileprivate var client: DockerClient
        
        /// Lists the plugins.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns  a  list of `Plugin`.
        public func list() async throws -> [Plugin] {
            return try await client.run(ListPluginsEndpoint())
        }
        
        
        /// Gets info about an installed Plugin by its name.
        /// - Parameter name: Name of the`Plugin` that should be fetched. The `:latest` tag is optional, and is the default if omitted.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Return the `Plugin`.
        public func get(_ name: String) async throws -> Plugin {
            return try await client.run(InspectPluginEndpoint(name: name))
        }
        
        /// Fetches the privileges required by a Plugin from the registry.
        /// - Parameter name: Name of the`Plugin`. Example: `vieux/sshfs:latest`. The `:latest` tag is optional, and is the default if omitted.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Return a list of the `PluginPrivilege` required by the plugin.
        public func getPrivileges(_ name: String) async throws -> [PluginPrivilege] {
            return try await client.run(GetPluginPrivilegesEndpoint(remote: name))
        }
        
        /// Pulls a Plugin from a remote registry and installs it.
        /// Note: the plugin must then be enabled in order to be used.
        /// - Parameters:
        ///   - remote: Image name of the plugin. Example: `vieux/sshfs:latest`
        ///   - alias: Optional custom local name  for the pulled plugin.
        ///   - privileges: Optional privileges to grant to the plugin. The list of privileges requested by the plugin can be obtained by calling `getPrivileges()`.
        ///   - credentials: Optional `RegistryAuth` as returned by `registries.login()`
        /// - Throws: Errors that can occur when executing the request.
        public func install(remote: String, alias: String? = nil, privileges: [PluginPrivilege]? = [], credentials: RegistryAuth? = nil) async throws {
            let endpoint = InstallPluginEndpoint(
                remote: remote,
                alias: alias,
                privileges: privileges,
                credentials: credentials
            )
            try await client.run(endpoint)
        }
        
        /// Passes configuration values to an installed plugin.
        /// - Parameters:
        ///   - name: Name of the installed plugin. Example: `vieux/sshfs:latest`
        ///   - config: List of values to set. Example: `["DEBUG=1"]`
        /// - Throws: Errors that can occur when executing the request.
        public func configure(name: String, config: [String]) async throws {
            let endpoint = ConfigurePluginEndpoint(
                name: name,
                config: config
            )
            try await client.run(endpoint)
        }
        
        /// Enables an installed plugin.
        /// - Parameters:
        ///   - name: Name of the `Plugin` to enable.
        /// - Throws: Errors that can occur when executing the request.
        public func enable(_ name: String) async throws {
            try await client.run(EnableDisablePluginEndpoint(name: name, enable: true))
        }
        
        /// Disables an installed plugin.
        /// - Parameters:
        ///   - name: Name of the `Plugin` to disable.
        /// - Throws: Errors that can occur when executing the request.
        public func disable(_ name: String) async throws {
            try await client.run(EnableDisablePluginEndpoint(name: name, enable: false))
        }
        
        /// Upgrades an installed Plugin.
        /// - Parameters:
        ///   - name: Name of the installed plugin, Example: `vieux/sshfs:v1`
        ///   - remote: Image name of the new plugin version. Example: `vieux/sshfs:v2`
        ///   - privileges: Optional privileges to grant to the plugin. The list of privileges requested by the plugin can be obtained by calling `getPrivileges()`.
        ///   - credentials: Optional `RegistryAuth` as returned by `registries.login()`
        /// - Throws: Errors that can occur when executing the request.
        public func upgrade(name: String, remote: String, privileges: [PluginPrivilege]? = [], credentials: RegistryAuth? = nil) async throws {
            let endpoint = UpgradePluginEndpoint(
                name: name,
                remote: remote,
                privileges: privileges,
                credentials: credentials
            )
            try await client.run(endpoint)
        }
        
        /// Removes an existing plugin.
        /// - Parameters:
        ///   - name: Name of the `Plugin` to delete.
        ///   - force: If `true`, disable the plugin before removing. This may result in issues if the plugin is in use by a container.
        /// - Throws: Errors that can occur when executing the request.
        public func remove(_ name: String, force: Bool? = false) async throws {
            try await client.run(RemovePluginEndpoint(name: name, force: force ?? false))
        }
    }
}
