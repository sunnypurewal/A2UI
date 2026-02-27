import SwiftUI

struct ResourcesView: View {
	@Environment(\.openURL) var openURL
    var body: some View {
        List {
			Text("A2UI on GitHub")
				.onTapGesture {
					openURL(URL(string:"https://github.com/google/a2ui")!)
				}
			Text(
"""
**Sample App**
The sample app attempts to demonstrate the correct functionality of the SwiftUI A2UI renderer and the link between:
1. A2UI component adjacency list
2. Data model
3. Rendered UI on screen

- For each component, the **data model** and the **component adjacency list** (2) are displayed as JSON.
- The bounds of the A2UI Surface are indicated by **green lines**.
- Some components have variants which can be specified through a **native** input control below the rendered component.

**Component Types**
- **Layout** components arrange child A2UI components.
- **Content** components display values from the data model and are non-interactive.
- **Input** components modify the data model.
They can also run functions from the A2UI basic catalog:
1. Validate input
2. Format strings
3. Perform logic operations
- **Navigation** components toggle between child A2UI components
- **Decoration** components consist of only the Divider component
""")
        }
		.listStyle(.plain)
		.padding()
        .navigationTitle("Resources")
    }
}

#Preview {
    NavigationView {
        ResourcesView()
    }
}
