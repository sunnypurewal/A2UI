import SwiftUI

struct A2UIJustifiedContainer: View {
    let childIds: [String]
    let justify: A2UIJustify

    var body: some View {
        if justify == .end || justify == .center || justify == .spaceEvenly || justify == .spaceAround {
            Spacer(minLength: 0)
        }

        ForEach(Array(childIds.enumerated()), id: \.offset) { index, id in
            A2UIComponentRenderer(componentId: id)
            if index < childIds.count - 1 {
                if justify == .spaceBetween || justify == .spaceEvenly || justify == .spaceAround {
                    Spacer(minLength: 0)
                }
            }
        }

        if justify == .start || justify == .center || justify == .spaceEvenly || justify == .spaceAround {
            Spacer(minLength: 0)
        }
    }
}
