import Testing
@testable import A2UI

struct ContainerPropertiesTests {
    @Test func resolvedJustify() {
        let props = ContainerProperties(children: .list([]), justify: nil, align: nil)
        #expect(props.resolvedJustify == .spaceBetween)
        
        let props2 = ContainerProperties(children: .list([]), justify: .center, align: nil)
        #expect(props2.resolvedJustify == .center)
    }

    @Test func resolvedAlign() {
        let props = ContainerProperties(children: .list([]), justify: nil, align: nil)
        #expect(props.resolvedAlign == .center)
        
        let props2 = ContainerProperties(children: .list([]), justify: nil, align: .start)
        #expect(props2.resolvedAlign == .start)
    }
}
