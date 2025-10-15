import OSLog
import Foundation

/// Severity levels emitted by ``JoyfillLogger``.
public enum LogType {
    /// Diagnostic message helpful during development.
    case debug
    /// Informational message about normal operation.
    case info
    /// Warning that indicates a potential problem.
    case warning
    /// Error that represents an unexpected or fatal condition.
    case error
    
    var icon: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
}

/// Lightweight logger that mirrors messages to the console during debug builds.
public final class JoyfillLogger {
    /// Shared singleton instance used by the global ``Log`` function.
    public static let shared = JoyfillLogger()
//    private let logger = Logger(subsystem: "com.joyfill", category: "default")
    
    private init() {}
    
    /// Writes a message with file/function metadata to the debug console.
    /// - Parameters:
    ///   - message: Message text to log.
    ///   - type: Severity associated with the message.
    ///   - function: Function name captured via default parameter.
    ///   - file: File name captured via default parameter.
    ///   - line: Line number captured via default parameter.
    public func log(
        _ message: String,
        type: LogType,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        let functionName = function
        let logMessage = "\(type.icon) [\(fileName):\(line)] \(functionName) → \(message)"
        
//        switch type {
//        case .debug:
//            logger.debug("\(logMessage)")
//        case .info:
//            logger.info("\(logMessage)")
//        case .warning:
//            logger.warning("\(logMessage)")
//        case .error:
//            logger.error("\(logMessage)")
//        }
        #if DEBUG
        print(logMessage) // Print to console in both debug and release builds
        if type == .error {
            #if DEBUG
            if NSClassFromString("XCTest") == nil {
                fatalError(logMessage) // Only crash if not running tests
            }
            #else
            print("Critical error logged: \(logMessage)") // Log error in production builds
            #endif
        }
        #endif
    }
}

/// Convenient global function for emitting Joyfill log messages.
public func Log(
    _ message: String,
    type: LogType = .info,
    function: String = #function,
    file: String = #file,
    line: Int = #line
) {
    JoyfillLogger.shared.log(
        message,
        type: type,
        function: function,
        file: file,
        line: line
    )
} 
