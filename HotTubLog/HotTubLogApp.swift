import SwiftUI
import SwiftData

@main
struct HotTubLogApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(
                for: EntryType.self,
                LogEntry.self,
                Measurement.self,
                FieldConfig.self,
                Reminder.self
            )
        } catch {
            fatalError("Failed to create model container: \(error)")
        }

        SeedData.ensureSeeded(context: container.mainContext)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
}
