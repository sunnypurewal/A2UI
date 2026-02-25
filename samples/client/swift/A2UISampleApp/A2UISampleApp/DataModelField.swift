import Foundation

struct DataModelField: Identifiable {
	enum Value {
		case string(String)
		case number(Double)
		case bool(Bool)
		case listObjects([[String: Any]])
	}
	
	let id = UUID()
	let path: String
	let label: String
	var value: Value
	
	func updateDataModelA2UI(surfaceId: String) -> String {
		let valueJson: String
		switch value {
			case .string(let stringValue):
				valueJson = jsonLiteral(from: stringValue)
			case .number(let numberValue):
				valueJson = "\(numberValue)"
			case .bool(let boolValue):
				valueJson = boolValue ? "true" : "false"
			case .listObjects(let listValue):
				valueJson = jsonArrayLiteral(from: listValue)
		}
		return #"{"version":"v0.10","updateDataModel":{"surfaceId":"\#(surfaceId)","path":"\#(path)","value":\#(valueJson)}}"#
	}
	
	private func jsonLiteral(from stringValue: String) -> String {
		if let data = stringValue.data(using: .utf8),
		   let object = try? JSONSerialization.jsonObject(with: data),
		   JSONSerialization.isValidJSONObject(object),
		   let jsonData = try? JSONSerialization.data(withJSONObject: object),
		   let jsonString = String(data: jsonData, encoding: .utf8) {
			return jsonString
		}
		
		guard let data = try? JSONSerialization.data(withJSONObject: [stringValue]),
			  let wrapped = String(data: data, encoding: .utf8),
			  wrapped.count >= 2 else {
			return "\"\""
		}
		
		return String(wrapped.dropFirst().dropLast())
	}
	
	private func jsonArrayLiteral(from listValue: [[String: Any]]) -> String {
		guard JSONSerialization.isValidJSONObject(listValue),
			  let jsonData = try? JSONSerialization.data(withJSONObject: listValue),
			  let jsonString = String(data: jsonData, encoding: .utf8) else {
			return "[]"
		}
		return jsonString
	}
}
