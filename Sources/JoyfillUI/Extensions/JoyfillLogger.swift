import OSLog
import Foundation

public enum LogType {
    case debug
    case info
    case warning
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

public final class JoyfillLogger {
    public static let shared = JoyfillLogger()
//    private let logger = Logger(subsystem: "com.joyfill", category: "default")
    
    private init() {}
    
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
            fatalError(logMessage) // Terminate program in debug builds for critical errors
            #else
            print("Critical error logged: \(logMessage)") // Log error in production builds
            #endif
        }
        #endif
    }
}

// Convenient global function for logging
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
