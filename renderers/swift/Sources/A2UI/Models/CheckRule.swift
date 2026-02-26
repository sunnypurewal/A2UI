import Foundation

public struct CheckRule: Codable, Sendable, Equatable {
    public let condition: BoundValue<Bool>
    public let message: String

    public init(condition: BoundValue<Bool>, message: String) {
        self.condition = condition
        self.message = message
    }
}
