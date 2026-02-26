import SwiftUI
import OSLog

/// A view that renders an A2UI surface by its ID.
public struct A2UISurfaceView: View {
    @Environment(A2UIDataStore.self) var dataStoreEnv: A2UIDataStore?
    var dataStore: A2UIDataStore?
    public let surfaceId: String
    
    private var activeDataStore: A2UIDataStore? { dataStore ?? dataStoreEnv }
	#if DEBUG
    private let log = OSLog(subsystem: "org.a2ui.renderer", category: "SurfaceView")
	#else
		private let log = OSLog.disabled
	#endif

    public init(surfaceId: String, dataStore: A2UIDataStore? = nil) {
        self.surfaceId = surfaceId
        self.dataStore = dataStore
    }

    public var body: some View {
        let _ = os_log("Rendering A2UISurfaceView for surfaceId: %{public}@", log: log, type: .debug, surfaceId)
        let surface = activeDataStore?.surfaces[surfaceId]
        let _ = os_log("Surface found in dataStore: %{public}@", log: log, type: .debug, String(describing: surface != nil))
        
        Group {
            if let surface = surface, surface.isReady {
                let _ = os_log("Surface is ready, attempting to render root.", log: log, type: .debug)
                if let rootId = surface.rootComponentId {
                    A2UIComponentRenderer(componentId: rootId, surface: surface)
                        .environment(surface)
                        .onAppear {
                            os_log("Surface rendered: %{public}@", log: log, type: .info, surfaceId)
                        }
                } else {
                    Text("Surface ready but no root component found.")
                        .onAppear {
                            os_log("Surface error: Ready but no root for %{public}@", log: log, type: .error, surfaceId)
                        }
                }
            } else {
                let _ = os_log("Surface not ready or not found. isReady: %{public}@", log: log, type: .debug, String(describing: surface?.isReady))
                VStack {
                    ProgressView()
                    Text("Waiting for A2UI stream...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
