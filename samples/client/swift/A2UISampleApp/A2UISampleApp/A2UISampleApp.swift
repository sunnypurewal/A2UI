import SwiftUI
import A2UI

@main
struct A2UIExplorerApp: App {
	@State private var dataStore = A2UIDataStore()
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environment(dataStore)
		}
	}
}
