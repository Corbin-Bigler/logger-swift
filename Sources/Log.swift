//
//  Log.swift
//  swift-logger
//
//  Created by Corbin Bigler on 4/23/25.
//

import Foundation

public struct Log: Sendable {
    public let date: Date = Date()
    public let tag: String
    public let message: String
    public let level: LogLevel
    public let secure: Bool
    public let metadata: [String: Sendable]
}
