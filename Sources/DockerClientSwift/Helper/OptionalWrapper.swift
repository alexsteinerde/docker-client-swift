// From the excellent CodableWrappers package at https://github.com/GottaGetSwifty/CodableWrappers
//
//  OptionalWrappers.swift
//
//  Copyright © 2019 PJ Fechner. All rights reserved.
import Foundation

//MARK: - OptionalWrapper
public protocol OptionalEncodingWrapper {
    associatedtype WrappedType: ExpressibleByNilLiteral
    var wrappedValue: WrappedType { get }
}

public protocol OptionalDecodingWrapper {
    associatedtype WrappedType: ExpressibleByNilLiteral
    init(wrappedValue: WrappedType)
}
/// Protocol for a PropertyWrapper to properly handle Coding when the wrappedValue is Optional
public typealias OptionalCodingWrapper = OptionalEncodingWrapper & OptionalDecodingWrapper


extension KeyedDecodingContainer {
    // This is used to override the default decoding behavior for OptionalWrapper to avoid a missing key Error
    public func decode<T>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> T where T : Decodable, T: OptionalDecodingWrapper {
        return try decodeIfPresent(T.self, forKey: key) ?? T(wrappedValue: nil)
    }
}

extension KeyedEncodingContainer {
    // Used to make make sure OptionalCodingWrappers encode no value when it's wrappedValue is nil.
    public mutating func encode<T>(_ value: T, forKey key: KeyedEncodingContainer<K>.Key) throws where T: Encodable, T: OptionalEncodingWrapper {
        
        if case Optional<Any>.none = value.wrappedValue as Any {
            return
        }
        
        try encodeIfPresent(value, forKey: key)
    }
}

public typealias OptionalCodableWrapper = OptionalEncodingWrapper & OptionalDecodingWrapper
