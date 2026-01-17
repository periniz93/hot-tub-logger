import SwiftUI
import SwiftData

struct RemindersView: View {
    @Query(sort: \EntryType.name) private var entryTypes: [EntryType]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Reminders are optional and use local notifications only.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                ForEach(entryTypes) { entryType in
                    if let reminder = entryType.reminders.first {
                        ReminderRowView(reminder: reminder, entryTypeName: entryType.name)
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(entryType.name)
                                .font(.headline)
                            Text("No reminder configured yet.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Reminders")
        }
    }
}
