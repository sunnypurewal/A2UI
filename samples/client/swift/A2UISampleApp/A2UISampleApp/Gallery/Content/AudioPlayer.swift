import Foundation
import A2UI

extension GalleryComponent {
	static let audioPlayer: Self = {
		return .init(
			id: "AudioPlayer",
			template: #"{"id":"gallery_component","component":{"AudioPlayer":{"url":{"path":"/url"}}}}"#,
			staticComponents: [.root],
			dataModelFields: [
				.init(path: "/url", label: "Video URL", value: .string("https://diviextended.com/wp-content/uploads/2021/10/sound-of-waves-marine-drive-mumbai.mp3"))
			],
			properties: []
		)
	}()
}
