import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    FieldConfigView()
                } label: {
                    Label("Field Builder", systemImage: "slider.horizontal.3")
                }

                NavigationLink {
                    PromptSettingsView()
                } label: {
                    Label("LLM Prompt", systemImage: "sparkles")
                }

                Section("Data") {
                    Text("All data is stored locally on this device.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
