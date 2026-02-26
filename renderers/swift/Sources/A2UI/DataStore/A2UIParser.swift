import Foundation
import OSLog

/// A parser that handles the JSONL stream and emits A2UIMessages.
public class A2UIParser {
    private let decoder = JSONDecoder()
	#if DEBUG
    private let log = OSLog(subsystem: "org.a2ui.renderer", category: "Parser")
	#else
		private let log = OSLog.disabled
	#endif

    public init() {}

    /// Parses a single line of JSON from the stream.
    /// - Parameter line: A single JSON string representing one or more A2UIMessages (comma-separated).
    /// - Returns: A list of decoded A2UIMessages.
    public func parse(line: String) throws -> [A2UIMessage] {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        
        guard let data = trimmed.data(using: .utf8) else {
            throw A2UIParserError.invalidEncoding
        }
        
        // Try decoding as a single message first
        do {
            let message = try decoder.decode(A2UIMessage.self, from: data)
            return [message]
        } catch {
            // If that fails, try wrapping in [] to see if it's a comma-separated list of objects
            // or if it's already an array.
            if trimmed.hasPrefix("[") && trimmed.hasSuffix("]") {
                return try decoder.decode([A2UIMessage].self, from: data)
            }
            
            let wrappedJson = "[\(trimmed)]"
            guard let wrappedData = wrappedJson.data(using: .utf8) else {
                throw error
            }
            
            do {
                return try decoder.decode([A2UIMessage].self, from: wrappedData)
            } catch {
                // If both fail, throw the original error
                throw error
            }
        }
    }

    /// Helper to process a chunk of text that may contain multiple lines.
    /// Useful for partial data received over a network stream.
    public func parse(chunk: String, remainder: inout String) -> [A2UIMessage] {
        let start = DispatchTime.now()
        
        let fullContent = remainder + chunk
        var lines = fullContent.components(separatedBy: .newlines)
        
        // The last element is either empty (if chunk ended in newline) 
        // or a partial line (the new remainder).
        remainder = lines.removeLast()
        
        var messages: [A2UIMessage] = []
        for line in lines {
            do {
                let parsedMessages = try parse(line: line)
                messages.append(contentsOf: parsedMessages)
            } catch {
                os_log("A2UI Parser Error: %{public}@ on line: %{public}@", log: log, type: .error, "\(error)", line)
            }
        }

        let end = DispatchTime.now()
        let diff = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000
        if !messages.isEmpty {
            os_log("Parsed %d messages in %.3fms", log: log, type: .debug, messages.count, diff)
        }
        
        return messages
    }
}

public enum A2UIParserError: Error {
    case invalidEncoding
}
