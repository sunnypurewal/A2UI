import SwiftUI

struct A2UIDividerView: View {
    var body: some View {
        Divider()
            .padding(.vertical, 4)
    }
}

#Preview {
    VStack {
        Text("Above")
        A2UIDividerView()
        Text("Below")
    }
    .padding()
}
