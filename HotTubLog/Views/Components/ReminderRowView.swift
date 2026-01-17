import SwiftUI
import SwiftData

struct ReminderRowView: View {
    @Bindable var reminder: Reminder
    let entryTypeName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $reminder.enabled) {
                Text(entryTypeName)
                    .font(.headline)
            }

            if reminder.enabled {
                HStack {
                    Stepper(value: $reminder.interval, in: 1...90) {
                        Text("Every \(reminder.interval)")
                    }
                    Spacer()
                    Picker("Unit", selection: $reminder.unitRaw) {
                        ForEach(ReminderUnit.allCases) { unit in
                            Text(unit.displayName + (reminder.interval == 1 ? "" : "s"))
                                .tag(unit.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Text(reminder.displayText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
        .onChange(of: reminder.enabled) { _ in
            scheduleReminder()
        }
        .onChange(of: reminder.interval) { _ in
            if reminder.enabled { scheduleReminder() }
        }
        .onChange(of: reminder.unitRaw) { _ in
            if reminder.enabled { scheduleReminder() }
        }
    }

    private func scheduleReminder() {
        Task {
            await NotificationScheduler.shared.updateSchedule(for: reminder, entryTypeName: entryTypeName)
        }
    }
}
