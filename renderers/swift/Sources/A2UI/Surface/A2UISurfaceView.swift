import SwiftUI
import OSLog

/// A view that renders an A2UI surface by its ID.
public struct A2UISurfaceView: View {
    @Environment(A2UIDataStore.self) var dataStoreEnv: A2UIDataStore?
    var dataStore: A2UIDataStore?
    public let surfaceId: String
    
    private var activeDataStore: A2UIDataStore? { dataStore ?? dataStoreEnv }

    public init(surfaceId: String, dataStore: A2UIDataStore? = nil) {
        self.surfaceId = surfaceId
        self.dataStore = dataStore
    }

    @ViewBuilder
    public var body: some View {
        if let surface = activeDataStore?.surfaces[surfaceId], surface.isReady {
            if let rootId = surface.rootComponentId {
                A2UIComponentRenderer(componentId: rootId, surface: surface)
                    .environment(surface)
            } else {
                Text("Surface ready but no root component found.")
            }
        } else {
            EmptyView()
        }
    }
}
