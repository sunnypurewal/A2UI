enum StaticComponent: String {
	case root = #"{"id":"root","component":{"Card":{"child":"gallery_component"}}}"#
	
	case valueText = #"{"id":"value_text","component":{"Text":{"text":{"path":"/value"},"variant":"body"}}}"#
	
	case h2 = #"{"id":"t_h2","component":{"Text":{"text":{"path":"/headline/text"},"variant":"h2"}}}"#
	case body = #"{"id":"t_body","component":{"Text":{"text":{"path":"/body/text"},"variant":"body"}}}"#
	case caption = #"{"id":"t_caption","component":{"Text":{"text":{"path":"/caption/text"},"variant":"caption"}}}"#
	
	case cardContentContainer = #"{"id":"card_content_container","component":{"Column":{"children":["card_content_top","card_content_bottom"],"justify":"spaceAround","align":"center"}}}"#
	case cardContentTop = #"{"id":"card_content_top","component":{"Row":{"children":["t_h2"],"justify":"start","align":"center"}}}"#
	case cardContentBottom = #"{"id":"card_content_bottom","component":{"Row":{"children":["t_body","t_caption"],"justify":"spaceBetween","align":"center"}}}"#
	
	case listH2 = #"{"id":"t_h2","component":{"Text":{"text":{"path":"headline"},"variant":"h2"}}}"#
	case listBody = #"{"id":"t_body","component":{"Text":{"text":{"path":"body"},"variant":"body"}}}"#
	case listCaption = #"{"id":"t_caption","component":{"Text":{"text":{"path":"caption"},"variant":"caption"}}}"#
	
	case tab1 = #"{"id":"tab1_content","component":{"Text":{"text":"Tab 1 Content"}}}"#
	case tab2 = #"{"id":"tab2_content","component":{"Text":{"text":"Tab 2 Content"}}}"#
	
	case modalContent = #"{"id":"modal_content","component":{"Text":{"text":"This is a modal"}}}"#
	case modalButton = #"{"id":"trigger_button","component":{"Button":{"child":"button_child","action":{"functionCall":{"call": "button_click"}}}}}"#
	
	case textFieldRoot = #"{"id":"root","component":{"Card":{"child":"text_field_preview"}}}"#
	case textFieldPreview = #"{"id":"text_field_preview","component":{"Column":{"children":["t_body","gallery_component"],"justify":"spaceBetween","align":"center"}}}"#
	
	case checkboxRoot = #"{"id":"root","component":{"Card":{"child":"check_box_preview"}}}"#
	case checkboxValue = #"{"id":"t_h2","component":{"Text":{"text":{"path":"/value"},"variant":"h2"}}}"#
	case checkboxPreview = #"{"id":"check_box_preview","component":{"Column":{"children":["t_h2","gallery_component"],"justify":"spaceBetween","align":"center"}}}"#
	
	case choicePickerRoot = #"{"id":"root","component":{"Card":{"child":"choice_picker_preview"}}}"#
	case choicePickerPreview = #"{"id":"choice_picker_preview","component":{"Column":{"children":["value_text","gallery_component"],"justify":"spaceAround","align":"center"}}}"#
	
	case sliderRoot = #"{"id":"root","component":{"Card":{"child":"slider_preview"}}}"#
	case sliderPreview = #"{"id":"slider_preview","component":{"Column":{"children":["value_text","gallery_component"],"justify":"spaceBetween","align":"center"}}}"#
	
	case datetimeRoot = #"{"id":"root","component":{"Card":{"child":"datetime_preview"}}}"#
	case datetimePreview = #"{"id":"datetime_preview","component":{"Column":{"children":["value_text","gallery_component"],"justify":"spaceAround","align":"center"}}}"#
	
	case buttonChild = #"{"id":"button_child","component":{"Text":{"text":"Tap Me"}}}"#
}
