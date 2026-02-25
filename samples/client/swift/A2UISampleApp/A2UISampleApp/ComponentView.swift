import SwiftUI
import A2UI

struct ComponentView: View {
	@Environment(A2UIDataStore.self) var dataStore
	let component: GalleryComponent
	
	var body: some View {
		VStack {
			A2UISurfaceView(surfaceId: component.id)
				.padding()
				.background(Color(.systemBackground))
				.cornerRadius(12)
				.shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
		}
		.onAppear {
			dataStore.process(chunk: component.a2ui)
			dataStore.flush()
		}
		.navigationTitle(component.id)
	}
}

#Preview {
	NavigationView {
		ComponentView(component: GalleryComponent.row)
	}
}
