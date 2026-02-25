import SwiftUI
import A2UI

struct SectionDetailView: View {
    let section: GalleryData.Section
    
    var body: some View {
        A2UISurfaceView(surfaceId: section.id.uuidString)
    }
}

struct ContentView: View {
    @Environment(A2UIDataStore.self) var dataStore
    @State private var jsonToShow: String?

    var body: some View {
        NavigationView {
			List(GalleryData.sections) { section in
                Section(header: Text(section.name)) {
                    VStack {
                        SectionDetailView(section: section)
                            .frame(height: 300)

                        Button(action: {
                            jsonToShow = section.prettyJson
                        }) {
                            Label("Show JSON", systemImage: "doc.text")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("A2UI Gallery")
        }
        .onAppear {
            for section in GalleryData.sections {
                dataStore.process(chunk: section.a2ui)
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
