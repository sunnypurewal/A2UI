import Testing
@testable import A2UI
import Foundation

struct A2UIMessageTests {
    @Test func a2UIMessageDecodeVersionError() {
        let json = """
        {
            "version": "v0.9",
            "createSurface": {"id": "1"}
        }
        """.data(using: .utf8)!
        
        #expect(throws: Error.self) {
            let error = try JSONDecoder().decode(A2UIMessage.self, from: json)
            return error
        } 
        
        // Detailed check if possible, but Swift Testing #expect(throws:) is more limited in inspecting error details in-line
        do {
            _ = try JSONDecoder().decode(A2UIMessage.self, from: json)
        } catch DecodingError.dataCorrupted(let context) {
            #expect(context.debugDescription.contains("Unsupported A2UI version"))
        } catch {
            Issue.record("Expected dataCorrupted error, got \(error)")
        }
    }
    
    @Test func a2UIMessageAppMessage() throws {
        let json = """
        {
            "customEvent": {"data": 123}
        }
        """.data(using: .utf8)!
        
        let message = try JSONDecoder().decode(A2UIMessage.self, from: json)
        if case let .appMessage(name, data) = message {
            #expect(name == "customEvent")
            #expect(data["customEvent"] != nil)
        } else {
            Issue.record("Expected appMessage")
        }
        
        let encoded = try JSONEncoder().encode(message)
        let decoded = try JSONDecoder().decode(A2UIMessage.self, from: encoded)
        if case let .appMessage(name2, data2) = decoded {
            #expect(name2 == "customEvent")
            #expect(data2["customEvent"] != nil)
        } else {
            Issue.record("Expected appMessage")
        }
    }

    @Test func a2UIMessageAppMessageMultipleKeys() throws {
        let json = """
        {
            "event1": {"a": 1},
            "event2": {"b": 2}
        }
        """.data(using: .utf8)!
        
        let message = try JSONDecoder().decode(A2UIMessage.self, from: json)
        if case let .appMessage(name, data) = message {
            #expect(name == "event1" || name == "event2")
            #expect(data.count == 2)
            
            let encoded = try JSONEncoder().encode(message)
            let decodedAgain = try JSONDecoder().decode(A2UIMessage.self, from: encoded)
            if case let .appMessage(_, data2) = decodedAgain {
                #expect(data2.count == 2)
            } else { Issue.record("Expected appMessage") }
        } else {
            Issue.record("Expected appMessage")
        }
    }
    
    @Test func a2UIMessageDecodeError() {
        let json = "{}".data(using: .utf8)!
        #expect(throws: Error.self) { try JSONDecoder().decode(A2UIMessage.self, from: json) }
    }

    @Test func a2UIMessageDeleteAndDataUpdate() throws {
        // Delete
        let deleteJson = """
        {
            "version": "v0.10",
            "deleteSurface": {"surfaceId": "s1"}
        }
        """.data(using: .utf8)!
        let deleteMsg = try JSONDecoder().decode(A2UIMessage.self, from: deleteJson)
        if case .deleteSurface(let ds) = deleteMsg {
            #expect(ds.surfaceId == "s1")
        } else { Issue.record("Expected deleteSurface") }
        
        let encodedDelete = try JSONEncoder().encode(deleteMsg)
        #expect(String(data: encodedDelete, encoding: .utf8)!.contains("deleteSurface"))

        // Data Model Update
        let updateJson = """
        {
            "version": "v0.10",
            "updateDataModel": {"surfaceId": "s1", "value": {"key": "value"}}
        }
        """.data(using: .utf8)!
        let updateMsg = try JSONDecoder().decode(A2UIMessage.self, from: updateJson)
        if case .dataModelUpdate(let dmu) = updateMsg {
            #expect(dmu.surfaceId == "s1")
            #expect(dmu.value == AnyCodable(["key": "value"] as [String: Sendable]))
        } else { Issue.record("Expected dataModelUpdate") }
    }
	
	@Test func a2UICreateSurface() throws {
		let createSurfaceJson = """
		{
			"version": "v0.10",
			"createSurface": {"surfaceId": "surface123","catalogId": "catalog456"}
		}
		""".data(using: .utf8)!
		let message = try JSONDecoder().decode(A2UIMessage.self, from: createSurfaceJson)
		if case .createSurface(let cs) = message {
			#expect(cs.surfaceId == "surface123")
			#expect(cs.catalogId == "catalog456")
			#expect(cs.theme == nil)
			#expect(cs.sendDataModel == nil)
		} else {
			Issue.record("Expected createSurface message")
		}
	}
}
