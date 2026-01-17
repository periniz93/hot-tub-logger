import Foundation
import SwiftData

@MainActor
enum SeedData {
    static func ensureSeeded(context: ModelContext) {
        let fetch = FetchDescriptor<EntryType>()
        let count = (try? context.fetchCount(fetch)) ?? 0
        guard count == 0 else { return }

        for seed in defaultEntryTypes() {
            let entryType = EntryType(
                name: seed.name,
                iconName: seed.iconName,
                colorHex: seed.colorHex,
                isBuiltIn: true
            )

            let allKinds = FieldKind.allCases.sorted { $0.defaultOrder < $1.defaultOrder }
            let configs = allKinds.enumerated().map { index, kind in
                let enabled = seed.fieldKinds.contains(kind)
                return FieldConfig(fieldKind: kind, enabled: enabled, order: index * 10, entryType: entryType)
            }
            entryType.fieldConfigs = configs

            let reminder = Reminder(
                enabled: false,
                interval: seed.defaultInterval,
                unit: seed.defaultUnit,
                entryType: entryType
            )
            entryType.reminders = [reminder]

            context.insert(entryType)
        }

        try? context.save()
    }

    private static func defaultEntryTypes() -> [SeedEntryType] {
        [
            SeedEntryType(
                name: "Water Test",
                iconName: "drop.fill",
                colorHex: "2F6FED",
                fieldKinds: [.ph, .sanitizer, .alkalinity, .hardness, .temperature, .notes, .photo],
                defaultInterval: 3,
                defaultUnit: .day
            ),
            SeedEntryType(
                name: "Shock",
                iconName: "bolt.fill",
                colorHex: "F5A623",
                fieldKinds: [.notes, .photo],
                defaultInterval: 7,
                defaultUnit: .day
            ),
            SeedEntryType(
                name: "Filter Clean",
                iconName: "line.3.horizontal.decrease.circle",
                colorHex: "7B61FF",
                fieldKinds: [.notes, .photo],
                defaultInterval: 14,
                defaultUnit: .day
            ),
            SeedEntryType(
                name: "Filter Replace",
                iconName: "arrow.triangle.2.circlepath",
                colorHex: "50C878",
                fieldKinds: [.notes, .photo],
                defaultInterval: 60,
                defaultUnit: .day
            ),
            SeedEntryType(
                name: "Drain / Refill",
                iconName: "arrow.down.circle.fill",
                colorHex: "1BA3A1",
                fieldKinds: [.notes, .photo],
                defaultInterval: 90,
                defaultUnit: .day
            ),
            SeedEntryType(
                name: "Custom",
                iconName: "sparkles",
                colorHex: "F06292",
                fieldKinds: [.notes, .photo],
                defaultInterval: 30,
                defaultUnit: .day
            )
        ]
    }
}

private struct SeedEntryType {
    let name: String
    let iconName: String
    let colorHex: String
    let fieldKinds: [FieldKind]
    let defaultInterval: Int
    let defaultUnit: ReminderUnit
}
