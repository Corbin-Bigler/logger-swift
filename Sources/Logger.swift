import Foundation

public actor Logger {
    private let continuation: AsyncStream<Log>.Continuation
    
    private var continuations: [String?: [UUID: (AsyncStream<Log>.Continuation, LogLevel)]] = [:]
    
    init() {
        var continuation: AsyncStream<Log>.Continuation!
        let stream = AsyncStream<Log> { continuation = $0 }
        self.continuation = continuation
        
        Task {
            for await log in stream {
                let (tagged, untagged) = await (
                    continuations[log.tag]?.values.flatMap({Array(arrayLiteral: $0)}) ?? [],
                    continuations[nil]?.values.flatMap({Array(arrayLiteral: $0)}) ?? []
                )
                
                for (continuation, level) in tagged + untagged where log.level.rawValue <= level.rawValue {
                    continuation.yield(log)
                }
            }
        }
    }
    
    public func stream(tag: String? = nil, level: LogLevel = .debug) -> AsyncStream<Log> {
        let id = UUID()
        return AsyncStream<Log> { continuation in
            continuations[tag, default: [:]][id] = (continuation, level)
            continuation.onTermination = { [weak self] _ in
                Task { await self?.removeContinuation(tag: tag, id: id) }
            }
        }
    }
    
    private func removeContinuation(tag: String?, id: UUID) {
        continuations[tag]?.removeValue(forKey: id)
    }

    nonisolated func log(_ log: Log) {
        continuation.yield(log)
    }
    
    nonisolated public func log(tag: String? = nil, _ message: Any, level: LogLevel, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        let tag = tag ?? file.split(separator: "/").last?.split(separator: ".").first.flatMap { String($0) } ?? file
        log(Log(tag: tag, message: "\(message)", level: level, secure: secure, metadata:  ["file": file,"fileID": fileID,"line": line,"column": column,"function": function]))
    }
    nonisolated public func fault(tag: String? = nil, _ message: Any, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(tag: tag, message, level: .fault, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    nonisolated public func error(tag: String? = nil, _ message: Any, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(tag: tag, message, level: .error, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    nonisolated public func info(tag: String? = nil, _ message: Any, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(tag: tag, message, level: .info, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    nonisolated public func debug(tag: String? = nil, _ message: Any, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(tag: tag, message, level: .debug, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }

    private static let shared = Logger()
    public static func log(tag: String? = nil, _ message: Any, level: LogLevel, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        shared.log(tag: tag, message, level: level, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    public static func fault(tag: String? = nil, _ message: Any, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(tag: tag, message, level: .fault, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    public static func error(tag: String? = nil, _ message: Any, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(tag: tag, message, level: .error, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    public static func info(tag: String? = nil, _ message: Any, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(tag: tag, message, level: .info, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    public static func debug(tag: String? = nil, _ message: Any, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(tag: tag, message, level: .debug, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
}
