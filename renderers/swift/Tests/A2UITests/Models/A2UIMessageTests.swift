import XCTest
@testable import A2UI

final class A2UIMessageTests: XCTestCase {
    func testA2UIMessageDecodeVersionError() {
        let json = """
        {
            "version": "v0.9",
            "createSurface": {"id": "1"}
        }
        """.data(using: .utf8)!
        
        XCTAssertThrowsError(try JSONDecoder().decode(A2UIMessage.self, from: json)) { error in
            if case let DecodingError.dataCorrupted(context) = error {
                XCTAssertTrue(context.debugDescription.contains("Unsupported A2UI version"))
            } else {
                XCTFail("Expected dataCorrupted error")
            }
        }
    }
    
    func testA2UIMessageAppMessage() throws {
        let json = """
        {
            "customEvent": {"data": 123}
        }
        """.data(using: .utf8)!
        
        let message = try JSONDecoder().decode(A2UIMessage.self, from: json)
        if case let .appMessage(name, data) = message {
            XCTAssertEqual(name, "customEvent")
            XCTAssertNotNil(data["customEvent"])
        } else {
            XCTFail("Expected appMessage")
        }
        
        let encoded = try JSONEncoder().encode(message)
        let decoded = try JSONDecoder().decode(A2UIMessage.self, from: encoded)
        if case let .appMessage(name2, data2) = decoded {
            XCTAssertEqual(name2, "customEvent")
            XCTAssertNotNil(data2["customEvent"])
        } else {
            XCTFail("Expected appMessage")
        }
    }

    func testA2UIMessageAppMessageMultipleKeys() throws {
        let json = """
        {
            "event1": {"a": 1},
            "event2": {"b": 2}
        }
        """.data(using: .utf8)!
        
        let message = try JSONDecoder().decode(A2UIMessage.self, from: json)
        if case let .appMessage(name, data) = message {
            XCTAssertTrue(name == "event1" || name == "event2")
            XCTAssertEqual(data.count, 2)
            
            let encoded = try JSONEncoder().encode(message)
            let decodedAgain = try JSONDecoder().decode(A2UIMessage.self, from: encoded)
            if case let .appMessage(_, data2) = decodedAgain {
                XCTAssertEqual(data2.count, 2)
            } else { XCTFail() }
        } else {
            XCTFail("Expected appMessage")
        }
    }
    
    func testA2UIMessageDecodeError() {
        let json = "{}".data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(A2UIMessage.self, from: json))
    }

    func testA2UIMessageDeleteAndDataUpdate() throws {
        // Delete
        let deleteJson = """
        {
            "version": "v0.10",
            "deleteSurface": {"surfaceId": "s1"}
        }
        """.data(using: .utf8)!
        let deleteMsg = try JSONDecoder().decode(A2UIMessage.self, from: deleteJson)
        if case .deleteSurface(let ds) = deleteMsg {
            XCTAssertEqual(ds.surfaceId, "s1")
        } else { XCTFail() }
        
        let encodedDelete = try JSONEncoder().encode(deleteMsg)
        XCTAssertTrue(String(data: encodedDelete, encoding: .utf8)!.contains("deleteSurface"))

        // Data Model Update
        let updateJson = """
        {
            "version": "v0.10",
            "updateDataModel": {"surfaceId": "s1", "value": {"key": "value"}}
        }
        """.data(using: .utf8)!
        let updateMsg = try JSONDecoder().decode(A2UIMessage.self, from: updateJson)
        if case .dataModelUpdate(let dmu) = updateMsg {
            XCTAssertEqual(dmu.surfaceId, "s1")
            XCTAssertEqual(dmu.value, AnyCodable(["key": "value"] as [String: Sendable]))
        } else { XCTFail() }
    }
	
	func testA2UICreateSurface() throws {
		let createSurfaceJson = """
		{
			"version": "v0.10",
			"createSurface": {"surfaceId": "surface123","catalogId": "catalog456"}
		}
		""".data(using: .utf8)!
		let message = try JSONDecoder().decode(A2UIMessage.self, from: createSurfaceJson)
		if case .createSurface(let cs) = message {
			XCTAssertEqual(cs.surfaceId, "surface123")
			XCTAssertEqual(cs.catalogId, "catalog456")
			XCTAssertNil(cs.theme)
			XCTAssertNil(cs.sendDataModel)
		} else {
			XCTFail("Expected createSurface message")
		}
	}
}
