enum StaticComponent: String {
	case h2 = #"{"id":"t_h2","component":{"Text":{"text":{"path":"/headline/text"},"variant":"h2"}}}"#
	case body = #"{"id":"t_body","component":{"Text":{"text":{"path":"/body/text"},"variant":"body"}}}"#
	case caption = #"{"id":"t_caption","component":{"Text":{"text":{"path":"/caption/text"},"variant":"caption"}}}"#
	case root = #"{"id":"root","component":{"Card":{"child":"gallery_component"}}}"#
	case cardContentContainer = #"{"id":"card_content_container","component":{"Column":{"children":["card_content_top","card_content_bottom"],"justify":"spaceAround","align":"center"}}}"#
	case cardContentTop = #"{"id":"card_content_top","component":{"Row":{"children":["t_h2"],"justify":"start","align":"center"}}}"#
	case cardContentBottom = #"{"id":"card_content_bottom","component":{"Row":{"children":["t_body","t_caption"],"justify":"spaceBetween","align":"center"}}}"#
	case listH2 = #"{"id":"t_h2","component":{"Text":{"text":{"path":"headline"},"variant":"h2"}}}"#
	case listBody = #"{"id":"t_body","component":{"Text":{"text":{"path":"body"},"variant":"body"}}}"#
	case listCaption = #"{"id":"t_caption","component":{"Text":{"text":{"path":"caption"},"variant":"caption"}}}"#
}
