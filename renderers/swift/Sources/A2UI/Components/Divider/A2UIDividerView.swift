import SwiftUI

struct A2UIDividerView: View {
	let properties: DividerProperties
    var body: some View {
        Divider()
            .padding(.vertical, 4)
    }
}

#Preview {
	VStack {
		VStack {
			Text("Above")
			A2UIDividerView(properties: .init(axis: .horizontal))
			Text("Below")
		}
		.padding()
		
		HStack {
			Text("Left")
			A2UIDividerView(properties: .init(axis: .horizontal))
			Text("Right")
		}
		.padding()
	}
}
