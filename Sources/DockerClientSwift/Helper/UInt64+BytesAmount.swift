//
//  File.swift
//  
//
//  Created by Matthieu Barthélemy on 25/6/22.
//

import Foundation


public extension UInt64 {
    /// Creates a bytes amount, im MegaBytes
    static func mb(_ value: Int) -> UInt64 {
        return UInt64(value * 1024 * 1024)
    }
    
    /// Creates a bytes amount, im GigaBytes
    static func gb(_ value: Int) -> UInt64 {
        return mb(value * 1024)
    }
}

public extension Int64 {
    /// Creates a bytes amount, im MegaBytes
    static func mb(_ value: Int) -> Int64 {
        return Int64(value * 1024 * 1024)
    }
    
    /// Creates a bytes amount, im GigaBytes
    static func gb(_ value: Int) -> Int64 {
        return mb(value * 1024)
    }
}
