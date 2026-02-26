import XCTest
@testable import A2UI

final class A2UIModelsTests: XCTestCase {

    // MARK: - FunctionCall Tests
    func testFunctionCallCodable() throws {
        let json = """
        {
            "call": "formatDate",
            "args": {"timestamp": 12345},
            "returnType": "String"
        }
        """.data(using: .utf8)!

        let call = try JSONDecoder().decode(FunctionCall.self, from: json)
        XCTAssertEqual(call.call, "formatDate")
        XCTAssertEqual(call.returnType, "String")
        XCTAssertEqual(call.args["timestamp"], AnyCodable(12345.0))

        let encoded = try JSONEncoder().encode(call)
        let decoded = try JSONDecoder().decode(FunctionCall.self, from: encoded)
        XCTAssertEqual(call, decoded)
        
        let emptyCall = FunctionCall(call: "empty")
        let emptyEncoded = try JSONEncoder().encode(emptyCall)
        let emptyDecoded = try JSONDecoder().decode(FunctionCall.self, from: emptyEncoded)
        XCTAssertEqual(emptyCall, emptyDecoded)
    }

    // MARK: - AnyCodable Tests
    func testAnyCodableJSONNull() throws {
        let json = "null".data(using: .utf8)!
        let val = try JSONDecoder().decode(AnyCodable.self, from: json)
        XCTAssertTrue(val.value is JSONNull)
        XCTAssertEqual(val, AnyCodable(JSONNull()))
        
        let encoded = try JSONEncoder().encode(val)
        XCTAssertEqual(String(data: encoded, encoding: .utf8), "null")
    }

    func testAnyCodableTypes() throws {
        let json = """
        {
            "string": "test",
            "bool": true,
            "double": 1.5,
            "array": [1.0, "two"],
            "dict": {"key": "value"}
        }
        """.data(using: .utf8)!

        let dict = try JSONDecoder().decode([String: AnyCodable].self, from: json)
        XCTAssertEqual(dict["string"], AnyCodable("test"))
        XCTAssertEqual(dict["bool"], AnyCodable(true))
        XCTAssertEqual(dict["double"], AnyCodable(1.5))
        
        let encoded = try JSONEncoder().encode(dict)
        let decodedDict = try JSONDecoder().decode([String: AnyCodable].self, from: encoded)
        
        XCTAssertEqual(dict["string"], decodedDict["string"])
        XCTAssertEqual(dict["bool"], decodedDict["bool"])
        XCTAssertEqual(dict["double"], decodedDict["double"])
        
        XCTAssertEqual(AnyCodable([1.0, "two"] as [Sendable]), AnyCodable([1.0, "two"] as [Sendable]))
    }
    
    func testAnyCodableDataCorrupted() throws {
        let invalidJson = #"{"test": "#.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(AnyCodable.self, from: invalidJson))
    }

    func testAnyCodableEquality() {
        XCTAssertEqual(AnyCodable(JSONNull()), AnyCodable(JSONNull()))
        XCTAssertEqual(AnyCodable("a"), AnyCodable("a"))
        XCTAssertNotEqual(AnyCodable("a"), AnyCodable("b"))
        XCTAssertEqual(AnyCodable(true), AnyCodable(true))
        XCTAssertEqual(AnyCodable(1.0), AnyCodable(1.0))
        
        let dict1: [String: Sendable] = ["a": 1.0]
        let dict2: [String: Sendable] = ["a": 1.0]
        XCTAssertEqual(AnyCodable(dict1), AnyCodable(dict2))
        
        let arr1: [Sendable] = [1.0, 2.0]
        let arr2: [Sendable] = [1.0, 2.0]
        XCTAssertEqual(AnyCodable(arr1), AnyCodable(arr2))
        
        XCTAssertNotEqual(AnyCodable("string"), AnyCodable(1.0))
    }

    func testAnyCodableArrayEncode() throws {
        let arr: [Sendable] = ["hello", 1.0, true]
        let val = AnyCodable(arr)
        let encoded = try JSONEncoder().encode(val)
        let decoded = try JSONDecoder().decode(AnyCodable.self, from: encoded)
        XCTAssertEqual(val, decoded)
    }

    func testJSONNull() throws {
        let nullVal = JSONNull()
        let encoded = try JSONEncoder().encode(nullVal)
        let decoded = try JSONDecoder().decode(JSONNull.self, from: encoded)
        XCTAssertEqual(nullVal, decoded)
        
        let invalid = "123".data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(JSONNull.self, from: invalid))
    }

    // MARK: - A2UIMessage Tests
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

    func testComponentTypeNames() {
        let cases: [(ComponentType, String)] = [
            (.text(TextProperties(text: .init(literal: ""), variant: nil)), "Text"),
            (.button(ButtonProperties(child: "c1", action: .custom(name: "", context: nil))), "Button"),
            (.column(ContainerProperties(children: .list([]), justify: nil, align: nil)), "Column"),
            (.row(ContainerProperties(children: .list([]), justify: nil, align: nil)), "Row"),
            (.card(CardProperties(child: "c1")), "Card"),
            (.divider(DividerProperties(axis: .horizontal)), "Divider"),
            (.image(ImageProperties(url: .init(literal: ""), fit: nil, variant: nil)), "Image"),
            (.list(ListProperties(children: .list([]), direction: nil, align: nil)), "List"),
            (.textField(TextFieldProperties(label: .init(literal: ""), value: .init(path: "p"))), "TextField"),
            (.choicePicker(ChoicePickerProperties(label: .init(literal: ""), options: [], value: .init(path: "p"))), "ChoicePicker"),
            (.dateTimeInput(DateTimeInputProperties(label: .init(literal: ""), value: .init(path: "p"))), "DateTimeInput"),
            (.slider(SliderProperties(label: .init(literal: ""), min: 0, max: 100, value: .init(path: "p"))), "Slider"),
            (.checkBox(CheckBoxProperties(label: .init(literal: ""), value: .init(path: "p"))), "CheckBox"),
            (.tabs(TabsProperties(tabs: [])), "Tabs"),
            (.icon(IconProperties(name: .init(literal: "star"))), "Icon"),
            (.modal(ModalProperties(trigger: "t1", content: "c1")), "Modal"),
            (.custom("MyComp", [:]), "MyComp")
        ]
        
        for (type, expectedName) in cases {
            XCTAssertEqual(type.typeName, expectedName)
        }
    }

    // MARK: - Action Tests
    func testActionDecodeEncode() throws {
        let customJson = """
        {
            "name": "submit",
            "context": {"key": "val"}
        }
        """.data(using: .utf8)!
        let customAction = try JSONDecoder().decode(Action.self, from: customJson)
        if case let .custom(name, context) = customAction {
            XCTAssertEqual(name, "submit")
            XCTAssertEqual(context?["key"], AnyCodable("val"))
        } else {
            XCTFail()
        }
        
        let eventJson = """
        {
            "event": {
                "name": "click",
                "context": {"key": "val"}
            }
        }
        """.data(using: .utf8)!
        let eventAction = try JSONDecoder().decode(Action.self, from: eventJson)
        if case let .custom(name, context) = eventAction {
            XCTAssertEqual(name, "click")
            XCTAssertEqual(context?["key"], AnyCodable("val"))
        } else {
            XCTFail()
        }
        
        let dataUpdateJson = """
        {
            "dataUpdate": {
                "path": "user.name",
                "contents": "John"
            }
        }
        """.data(using: .utf8)!
        let dataUpdateAction = try JSONDecoder().decode(Action.self, from: dataUpdateJson)
        if case let .dataUpdate(du) = dataUpdateAction {
            XCTAssertEqual(du.path, "user.name")
            XCTAssertEqual(du.contents, AnyCodable("John"))
        } else {
            XCTFail()
        }
        
        let functionCallJson = """
        {
            "functionCall": {
                "call": "doSomething"
            }
        }
        """.data(using: .utf8)!
        let functionCallAction = try JSONDecoder().decode(Action.self, from: functionCallJson)
        if case let .functionCall(fc) = functionCallAction {
            XCTAssertEqual(fc.call, "doSomething")
        } else {
            XCTFail()
        }
        
        // Error case
        let invalidJson = """
        { "invalid": true }
        """.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(Action.self, from: invalidJson))
        
        // Encoding Custom Action
        let encodedCustom = try JSONEncoder().encode(customAction)
        let decodedCustom = try JSONDecoder().decode(Action.self, from: encodedCustom)
        if case let .custom(name, context) = decodedCustom {
            XCTAssertEqual(name, "submit")
            XCTAssertEqual(context?["key"], AnyCodable("val"))
        }
    }

    // MARK: - BoundValue Tests
    func testBoundValueDecodeEncode() throws {
        // Literal Int -> gets decoded as Double via literal fallback
        let literalJson = "42".data(using: .utf8)!
        let literalVal = try JSONDecoder().decode(BoundValue<Double>.self, from: literalJson)
        XCTAssertEqual(literalVal.literal, 42.0)
        XCTAssertNil(literalVal.path)
        
        // Path
        let pathJson = #"{"path": "user.age"}"#.data(using: .utf8)!
        let pathVal = try JSONDecoder().decode(BoundValue<Double>.self, from: pathJson)
        XCTAssertEqual(pathVal.path, "user.age")
        XCTAssertNil(pathVal.literal)
        XCTAssertNil(pathVal.functionCall)
        
        // Function Call
        let funcJson = #"{"call": "getAge"}"#.data(using: .utf8)!
        let funcVal = try JSONDecoder().decode(BoundValue<Double>.self, from: funcJson)
        XCTAssertNotNil(funcVal.functionCall)
        XCTAssertEqual(funcVal.functionCall?.call, "getAge")
        
        // Encode
        let encodedLiteral = try JSONEncoder().encode(literalVal)
        let decodedLiteral = try JSONDecoder().decode(BoundValue<Double>.self, from: encodedLiteral)
        XCTAssertEqual(decodedLiteral.literal, 42.0)
        
        let encodedPath = try JSONEncoder().encode(pathVal)
        let decodedPath = try JSONDecoder().decode(BoundValue<Double>.self, from: encodedPath)
        XCTAssertEqual(decodedPath.path, "user.age")
        
        let encodedFunc = try JSONEncoder().encode(funcVal)
        let decodedFunc = try JSONDecoder().decode(BoundValue<Double>.self, from: encodedFunc)
        XCTAssertEqual(decodedFunc.functionCall?.call, "getAge")
    }

    // MARK: - Children Tests
    func testChildrenDecodeEncode() throws {
        let listJson = #"["child1", "child2"]"#.data(using: .utf8)!
        let listVal = try JSONDecoder().decode(Children.self, from: listJson)
        if case let .list(items) = listVal {
            XCTAssertEqual(items, ["child1", "child2"])
        } else { XCTFail() }
        
        let templateJson = #"{"componentId": "item", "path": "items"}"#.data(using: .utf8)!
        let templateVal = try JSONDecoder().decode(Children.self, from: templateJson)
        if case let .template(t) = templateVal {
            XCTAssertEqual(t.componentId, "item")
            XCTAssertEqual(t.path, "items")
        } else { XCTFail() }
        
        // Legacy wrappers
        let explicitListJson = #"{"explicitList": ["child1"]}"#.data(using: .utf8)!
        let explicitListVal = try JSONDecoder().decode(Children.self, from: explicitListJson)
        if case let .list(items) = explicitListVal {
            XCTAssertEqual(items, ["child1"])
        } else { XCTFail() }
        
        let explicitTemplateJson = #"{"template": {"componentId": "c", "path": "p"}}"#.data(using: .utf8)!
        let explicitTemplateVal = try JSONDecoder().decode(Children.self, from: explicitTemplateJson)
        if case let .template(t) = explicitTemplateVal {
            XCTAssertEqual(t.componentId, "c")
        } else { XCTFail() }
        
        // Error
        let invalidJson = #"{"invalid": true}"#.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(Children.self, from: invalidJson))
        
        // Encode
        let encodedList = try JSONEncoder().encode(listVal)
        let decodedList = try JSONDecoder().decode(Children.self, from: encodedList)
        if case let .list(items) = decodedList { XCTAssertEqual(items, ["child1", "child2"]) }
        
        let encodedTemplate = try JSONEncoder().encode(templateVal)
        let decodedTemplate = try JSONDecoder().decode(Children.self, from: encodedTemplate)
        if case let .template(t) = decodedTemplate { XCTAssertEqual(t.componentId, "item") }
    }

    func testComponentInstanceFullInit() throws {
        let textType = ComponentType.text(TextProperties(text: BoundValue(literal: "Test"), variant: nil))
        let check = CheckRule(condition: BoundValue<Bool>(literal: true), message: "msg")
        let comp = ComponentInstance(id: "1", weight: 2.5, checks: [check], component: textType)
        
        XCTAssertEqual(comp.id, "1")
        XCTAssertEqual(comp.weight, 2.5)
        XCTAssertEqual(comp.checks?.count, 1)
        XCTAssertEqual(comp.componentTypeName, "Text")
        
        let encoded = try JSONEncoder().encode(comp)
        let decoded = try JSONDecoder().decode(ComponentInstance.self, from: encoded)
        XCTAssertEqual(decoded.id, "1")
        XCTAssertEqual(decoded.weight, 2.5)
    }
}
