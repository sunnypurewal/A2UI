import Foundation
import Testing
@testable import A2UI

@MainActor
struct FormatDateTests {
    private let surface = SurfaceState(id: "test")
    
    /// Returns a fixed timestamp (2026-02-26 12:00:00) in the LOCAL timezone.
    private func getLocalTimestamp() throws -> Double {
        var components = DateComponents()
        components.year = 2026
        components.month = 2
        components.day = 26
        components.hour = 12
        components.minute = 0
        components.second = 0
		let date: Date! = Calendar.current.date(from: components)
		try #require(date != nil, "Failed to create date from components")
        return date.timeIntervalSince1970
    }

    @Test func formatDate() throws {
        let timestamp = try getLocalTimestamp()
        let call = FunctionCall.formatDate(value: timestamp, format: "yyyy-MM-dd")
		let result: String! = A2UIStandardFunctions.evaluate(call: call, surface: surface) as? String
		try #require(result != nil)
        #expect(result == "2026-02-26")
    }
	
	@Test func formatISO8601DateString() throws {
        let timestamp = try getLocalTimestamp()
		let date = Date(timeIntervalSince1970: timestamp)
		let isoFormatter = ISO8601DateFormatter()
        isoFormatter.timeZone = .current // Match system
		let systemFormatted = isoFormatter.string(from: date)
        
		let call = FunctionCall.formatDate(value: systemFormatted, format: "yyyy-MM-dd")
		let result: String! = A2UIStandardFunctions.evaluate(call: call, surface: surface) as? String
		try #require(result != nil)
		#expect(result == "2026-02-26")
	}
	
	@Test func formatNonStandardLongDateString() throws {
        let timestamp = try getLocalTimestamp()
		let date = Date(timeIntervalSince1970: timestamp)
		let systemFormatted = date.formatted(date: .long, time: .omitted)
		let call = FunctionCall.formatDate(value: systemFormatted, format: "yyyy-MM-dd")
		let result: String! = A2UIStandardFunctions.evaluate(call: call, surface: surface) as? String
		try #require(result != nil)
		#expect(result == "2026-02-26")
	}
	
	@Test func formatNonStandardShortDateString() throws {
        let timestamp = try getLocalTimestamp()
		let date = Date(timeIntervalSince1970: timestamp)
		let systemFormatted = date.formatted(date: .abbreviated, time: .shortened)
		let call = FunctionCall.formatDate(value: systemFormatted, format: "yyyy-MM-dd")
		let result: String! = A2UIStandardFunctions.evaluate(call: call, surface: surface) as? String
		try #require(result != nil)
		#expect(result == "2026-02-26")
	}

    @Test func formatDateEdgeCases() async {
        let date = Date(timeIntervalSince1970: 0)
        let call1 = FunctionCall.formatDate(value: date, format: "yyyy")
        let res1 = A2UIStandardFunctions.evaluate(call: call1, surface: surface) as? String
        #expect(res1 == "1970" || res1 == "1969")

        let call2 = FunctionCall.formatDate(value: "1970-01-01T00:00:00Z", format: "yyyy")
        let res2 = A2UIStandardFunctions.evaluate(call: call2, surface: surface) as? String
        #expect(res2 == "1970" || res2 == "1969")

        let call3 = FunctionCall.formatDate(value: "bad-date", format: "yyyy")
        #expect(A2UIStandardFunctions.evaluate(call: call3, surface: surface) as? String == "bad-date")

        let call4 = FunctionCall(call: "formatDate", args: [
            "value": AnyCodable(["a", "b"] as [Sendable]),
            "format": AnyCodable("yyyy")
        ])
        let result4 = A2UIStandardFunctions.evaluate(call: call4, surface: surface) as? String
        #expect(result4 != nil)
    }
}
