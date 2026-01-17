import Foundation
import SwiftData

@Model
final class EntryType {
    @Attribute(.unique) var id: UUID
    var name: String
    var iconName: String
    var colorHex: String
    var isBuiltIn: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade) var fieldConfigs: [FieldConfig]
    @Relationship(deleteRule: .cascade) var reminders: [Reminder]
    @Relationship(deleteRule: .cascade) var entries: [LogEntry]

    init(
        id: UUID = UUID(),
        name: String,
        iconName: String,
        colorHex: String,
        isBuiltIn: Bool = true,
        createdAt: Date = Date(),
        fieldConfigs: [FieldConfig] = [],
        reminders: [Reminder] = [],
        entries: [LogEntry] = []
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.isBuiltIn = isBuiltIn
        self.createdAt = createdAt
        self.fieldConfigs = fieldConfigs
        self.reminders = reminders
        self.entries = entries
    }
}
