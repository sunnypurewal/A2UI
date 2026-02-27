import Testing
@testable import A2UI
import Foundation

struct ComponentInstanceTests {
    @Test func componentInstanceFullInit() throws {
        let textType = ComponentType.text(TextProperties(text: BoundValue(literal: "Test"), variant: nil))
        let check = CheckRule(condition: BoundValue<Bool>(literal: true), message: "msg")
        let comp = ComponentInstance(id: "1", weight: 2.5, checks: [check], component: textType)
        
        #expect(comp.id == "1")
        #expect(comp.weight == 2.5)
        #expect(comp.checks?.count == 1)
        #expect(comp.componentTypeName == "Text")
        
        let encoded = try JSONEncoder().encode(comp)
        let decoded = try JSONDecoder().decode(ComponentInstance.self, from: encoded)
        #expect(decoded.id == "1")
        #expect(decoded.weight == 2.5)
    }
}
