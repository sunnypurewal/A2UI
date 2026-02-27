import Foundation

/// Internal logger for A2UI.
/// By default, all logging is disabled to avoid spamming the console of host applications.
/// To enable logging during development of the library, add 'A2UI_DEBUG' to your active compilation conditions.
enum A2UILogger {
    @inline(__always)
    static func debug(_ message: @autoclosure () -> String) {
        #if A2UI_DEBUG
        print("[A2UI DEBUG] \(message())")
        #endif
    }
    
    @inline(__always)
    static func info(_ message: @autoclosure () -> String) {
        #if A2UI_DEBUG
        print("[A2UI INFO] \(message())")
        #endif
    }

    @inline(__always)
    static func warning(_ message: @autoclosure () -> String) {
        #if A2UI_DEBUG
        print("[A2UI WARNING] \(message())")
        #endif
    }
    
    @inline(__always)
    static func error(_ message: @autoclosure () -> String) {
        #if A2UI_DEBUG
        print("[A2UI ERROR] \(message())")
        #endif
    }
}
