import SwiftUI
import A2UI

struct ContentView: View {
    @Environment(A2UIDataStore.self) var dataStore
    @State private var jsonToShow: String?

    var body: some View {
        NavigationView {
			List(GalleryData.sections) { section in
				Section(section.name) {
					SectionDetailView(section: section, jsonToShow: $jsonToShow)
				}
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("A2UI Gallery")
        }
        .onAppear {
            for section in GalleryData.sections {
				for subsection in section.subsections {
					dataStore.process(chunk: subsection.a2ui)
				}
            }
            dataStore.flush()
        }
        .sheet(isPresented: Binding(
            get: { jsonToShow != nil },
            set: { if !$0 { jsonToShow = nil } }
        )) {
            NavigationView {
                ScrollView {
                    Text(jsonToShow ?? "")
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .navigationTitle("A2UI JSON")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            jsonToShow = nil
                        }
                    }
                }
            }
        }
    }
}
