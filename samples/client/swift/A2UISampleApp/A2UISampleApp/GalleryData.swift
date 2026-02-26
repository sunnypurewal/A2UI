import Foundation
import A2UI

struct GalleryData {
	static func components(for category: ComponentCategory) -> [GalleryComponent] {
		switch category {
			case .layout:
				return [.row, .column, .list]
			case .content:
				return [.text, .image, .icon, .video, .audioPlayer]
			case .input:
				return []
			case .navigation:
				return []
			case .decoration:
				return []
		}
	}
}

