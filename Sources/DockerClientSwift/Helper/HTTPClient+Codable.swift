//===----------------------------------------------------------------------===//
//
// This source file is part of the AsyncHTTPClient open source project
//
// Copyright (c) 2018-2019 Swift Server Working Group and the AsyncHTTPClient project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of AsyncHTTPClient project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation
import NIO
import AsyncHTTPClient
import Logging

extension EventLoopFuture where Value == HTTPClient.Response {
    /// Logs the response body to the specififed logger.
    /// - Parameter logger: Logger the message should be logged to.
    /// - Returns: Returnes the original response of the `HTTPClient`.
    func logResponseBody(_ logger: Logger) -> EventLoopFuture<HTTPClient.Response> {
        self.always({ ( result: Result<HTTPClient.Response, Error>) in
            logger.debug("Response: \(result.bodyValue() ?? "No Body Data")")
        })
    }
}

extension Result where Success == HTTPClient.Response {
    func bodyValue() -> String? {
        (try? self.get()).flatMap({ response -> String? in
            if let bodyData = response.bodyData {
                return String(data: bodyData, encoding: .utf8)
            } else {
                return nil
            }
        })
    }
}

extension EventLoopFuture where Value == HTTPClient.Response {
    
    public enum BodyError : Swift.Error {
        case noBodyData
    }
    
    /// Decode the response body as T using the given decoder.
    ///
    /// - parameters:
    ///     - type: The type to decode.  Must conform to Decoable.
    ///     - decoder: The decoder used to decode the reponse body.  Defaults to JSONDecoder.
    /// - returns: A future decoded type.
    /// - throws: BodyError.noBodyData when no body is found in reponse.
    public func decode<T : Decodable>(as type: T.Type, decoder: Decoder = JSONDecoder()) -> EventLoopFuture<T> {
        flatMapThrowing { response -> T in
            try response.checkStatusCode()
            if T.self == NoBody.self || T.self == NoBody?.self {
                return NoBody() as! T
            }
            
            guard let bodyData = response.bodyData else {
                throw BodyError.noBodyData
            }
            if T.self == String.self {
                return String(data: bodyData, encoding: .utf8) as! T
            }
            return try decoder.decode(type, from: bodyData)
        }
    }
    
    public func mapString<T>(map: @escaping (String) throws -> T) -> EventLoopFuture<T> {
        flatMapThrowing { (response) -> T in
            try response.checkStatusCode()
            guard let bodyData = response.bodyData else {
                throw BodyError.noBodyData
            }
            guard let string = String(data: bodyData, encoding: .utf8) else {
                throw BodyError.noBodyData
            }
            return try map(string)
        }
    }
    
    /// Decode the response body as T using the given decoder.
    ///
    /// - parameters:
    ///     - type: The type to decode.  Must conform to Decoable.
    ///     - decoder: The decoder used to decode the reponse body.  Defaults to JSONDecoder.
    /// - returns: A future optional decoded type.  The future value will be nil when no body is present in the response.
    public func decode<T : Decodable>(as type: T.Type, decoder: Decoder = JSONDecoder()) -> EventLoopFuture<T?> {
        flatMapThrowing { response -> T? in
            try response.checkStatusCode()
            guard let bodyData = response.bodyData else {
                return nil
            }
            
            return try decoder.decode(type, from: bodyData)
        }
    }
}

extension HTTPClient.Response {
    
    /// This function checks the current response fot the status code. If it is not in the range of `200...299` it throws an error
    /// - Throws: Throws a `DockerError.errorCode` error. If the response is a `MessageResponse` it uses the `message` content for the message, otherwise the body will be used.
    fileprivate func checkStatusCode() throws {
        guard 200...299 ~= self.status.code else {
            if let data = self.bodyData, let message = try? MessageResponse.decode(from: data) {
                throw DockerError.errorCode(Int(self.status.code), message.message)
            } else {
                throw DockerError.errorCode(Int(self.status.code), self.bodyData.map({ String(data: $0, encoding: .utf8) ?? "" }))
            }
        }
    }
    
    public var bodyData : Data? {
        guard let bodyBuffer = body,
            let bodyBytes = bodyBuffer.getBytes(at: bodyBuffer.readerIndex, length: bodyBuffer.readableBytes) else {
            return nil
        }
        
        return Data(bodyBytes)
    }
    
}

public protocol Decoder {
    func decode<T>(_ type: T.Type, from: Data) throws -> T where T : Decodable
}

extension JSONDecoder : Decoder {}
