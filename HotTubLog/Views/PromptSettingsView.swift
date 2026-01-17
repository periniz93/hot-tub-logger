import SwiftUI
import SwiftData
import UIKit

struct PromptSettingsView: View {
    @Query(sort: \LogEntry.timestamp, order: .reverse) private var entries: [LogEntry]
    @AppStorage("llm_prompt_template") private var template: String = PromptSettingsView.defaultTemplate
    @State private var copied = false

    var body: some View {
        Form {
            Section("Template") {
                TextEditor(text: $template)
                    .frame(minHeight: 160)
            }

            Section("Helper") {
                Button("Copy Prompt with Recent Logs") {
                    let prompt = LLMPromptBuilder.buildPrompt(template: template, entries: entries)
                    UIPasteboard.general.string = prompt
                    copied = true
                }

                if copied {
                    Text("Copied to clipboard")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("LLM Prompt")
    }

    static let defaultTemplate = "You are a hot tub maintenance assistant. Review my recent logs and suggest any next steps or potential issues. Keep it concise."
}
