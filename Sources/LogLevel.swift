//
//  LogLevel.swift
//  swift-logger
//
//  Created by Corbin Bigler on 4/23/25.
//

import OSLog

public enum LogLevel: Int, Sendable {
    case fault = 1
    case error = 2
    case info = 3
    case debug = 4
    
    var osLogType: OSLogType {
        switch self {
        case .fault: return .fault
        case .error: return .error
        case .info: return .info
        case .debug: return .debug
        }
    }
}
