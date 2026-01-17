import Foundation
import SwiftData

@Model
final class Reminder {
    @Attribute(.unique) var id: UUID
    var enabled: Bool
    var interval: Int
    var unitRaw: String
    var nextFireDate: Date?

    var entryType: EntryType?

    init(
        id: UUID = UUID(),
        enabled: Bool = false,
        interval: Int = 7,
        unit: ReminderUnit = .day,
        nextFireDate: Date? = nil,
        entryType: EntryType? = nil
    ) {
        self.id = id
        self.enabled = enabled
        self.interval = interval
        self.unitRaw = unit.rawValue
        self.nextFireDate = nextFireDate
        self.entryType = entryType
    }

    var unit: ReminderUnit {
        get { ReminderUnit(rawValue: unitRaw) ?? .day }
        set { unitRaw = newValue.rawValue }
    }

    var displayText: String {
        let unitText = interval == 1 ? unit.displayName : "\(unit.displayName)s"
        return "Every \(interval) \(unitText)"
    }
}
