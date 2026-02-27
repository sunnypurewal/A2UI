import Foundation
import A2UI

struct GalleryData {
	static func components(for category: ComponentCategory) -> [GalleryComponent] {
		switch category {
			case .layout:
				return [.column, .list, .row]
			case .content:
				return [.audioPlayer, .icon, .image, .text, .video]
			case .input:
				return [.button, .checkbox, .choicePicker, .dateTimeInput, .slider, .textField]
			case .navigation:
				return [.modal, .tabs]
			case .decoration:
				return [.divider]
			case .functions:
				return [.emailFunction, .requiredFunction, .lengthFunction, .regexFunction, .numericFunction, .formatDateFunction, .formatCurrencyFunction, .pluralizeFunction]
		}
	}
}
