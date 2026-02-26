import Foundation

public struct ChoicePickerProperties: Codable, Sendable {
    public let label: BoundValue<String>?
    public let options: [SelectionOption]
    public let variant: String? // multipleSelection, mutuallyExclusive
    public let value: BoundValue<[String]>
}

public struct SelectionOption: Codable, Sendable {
    public let label: BoundValue<String>
    public let value: String
}
