import SwiftUI
import SwiftData

struct FieldConfigDetailView: View {
    @Bindable var entryType: EntryType

    var body: some View {
        Form {
            Section("Fields") {
                ForEach(sortedConfigs) { config in
                    FieldConfigRowView(config: config)
                }
            }
        }
        .navigationTitle(entryType.name)
    }

    private var sortedConfigs: [FieldConfig] {
        entryType.fieldConfigs.sorted { $0.order < $1.order }
    }
}
