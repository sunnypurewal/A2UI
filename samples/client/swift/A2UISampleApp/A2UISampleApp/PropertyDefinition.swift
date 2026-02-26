import Foundation

struct PropertyDefinition: Identifiable {
	var id: String { key }
	let key: String
	let label: String
	let options: [String]
	var value: String
	var minValue: Double?
	var maxValue: Double?
	var isBoolean: Bool
	var isDate: Bool

	init(key: String, label: String, options: [String] = [], value: String, minValue: Double? = nil, maxValue: Double? = nil, isBoolean: Bool = false, isDate: Bool = false) {
		self.key = key
		self.label = label
		self.options = options
		self.value = value
		self.minValue = minValue
		self.maxValue = maxValue
		self.isBoolean = isBoolean
		self.isDate = isDate
	}
}

let justifyKey = "justify"
let alignKey = "align"
let variantKey = "variant"
let fitKey = "fit"
let iconNameKey = "iconName"
let textFieldVariantKey = "textFieldVariant"
let axisKey = "axis"
let choicePickerVariantKey = "choicePickerVariant"
let minKey = "min"
let maxKey = "max"
let enableDateKey = "enableDate"
let enableTimeKey = "enableTime"
