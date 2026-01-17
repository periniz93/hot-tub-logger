import Foundation
import SwiftData

@Model
final class FieldConfig {
    @Attribute(.unique) var id: UUID
    var fieldKindRaw: String
    var enabled: Bool
    var order: Int

    var entryType: EntryType?

    init(
        id: UUID = UUID(),
        fieldKind: FieldKind,
        enabled: Bool,
        order: Int,
        entryType: EntryType? = nil
    ) {
        self.id = id
        self.fieldKindRaw = fieldKind.rawValue
        self.enabled = enabled
        self.order = order
        self.entryType = entryType
    }

    var fieldKind: FieldKind {
        get { FieldKind(rawValue: fieldKindRaw) ?? .notes }
        set { fieldKindRaw = newValue.rawValue }
    }
}
