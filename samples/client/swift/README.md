# Sample App
The sample app attempts to demonstrate the correct functionality of the SwiftUI A2UI renderer.

It shows the link between 3 components of A2UI
1. Component adjacency list
2. Data model
3. Rendered UI

### Gallery ###
- Each component can be viewed in the Gallery
- The **data model** and the **component adjacency list** are displayed as JSON.
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