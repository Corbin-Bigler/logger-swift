import Testing
import Foundation
@testable import Logger

final class LoggerTests {
    @Test func testNoTagNoLevel() async throws {
        let logger = Logger()
        
        let stream = await logger.stream()
        
        let message = UUID().uuidString
        Task { logger.debug(tag: UUID().uuidString, message) }
        
        for await log in stream {
            #expect(log.message == message)
            return
        }
    }
    
    @Test func testTagLevel() async throws {
        let logger = Logger()
        
        let level = LogLevel.error
        let tag = UUID().uuidString
        let stream = await logger.stream(tag: tag, level: level)
        
        let message = UUID().uuidString
        Task {
            logger.debug(tag: tag, message)
            logger.info(tag: tag, message)
            logger.error(tag: tag, message)
            logger.error(tag: UUID().uuidString, message)
            logger.fault(tag: tag, message)
        }
        
        var error = false
        for await log in stream {
            #expect(log.message == message)
            #expect(log.tag == tag)
            if !error {
                #expect(log.level == .error)
                error = true
            } else {
                #expect(log.level == .fault)
                return
            }
        }
    }
}
