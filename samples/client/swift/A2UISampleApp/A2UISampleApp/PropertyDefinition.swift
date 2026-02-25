import Foundation

struct PropertyDefinition: Identifiable {
	var id: String { key }
	let key: String
	let label: String
	let options: [String]
	var value: String
}

let justifyKey = "justify"
let alignKey = "align"
let variantKey = "variant"
let fitKey = "fit"
let iconNameKey = "iconName"
