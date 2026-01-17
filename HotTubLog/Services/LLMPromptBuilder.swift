import Foundation

enum LLMPromptBuilder {
    static func buildPrompt(template: String, entries: [LogEntry]) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        let entryLines = entries.sorted(by: { $0.timestamp > $1.timestamp }).prefix(5).map { entry in
            let typeName = entry.entryType?.name ?? "Entry"
            let date = formatter.string(from: entry.timestamp)
            let measurementText = measurementSummary(for: entry)
            let notesText = entry.notes.isEmpty ? "" : "Notes: \(entry.notes)"
            let parts = ["\(typeName) (\(date))", measurementText, notesText]
                .filter { !$0.isEmpty }
                .joined(separator: " | ")
            return "- \(parts)"
        }

        var prompt = template
        if !entryLines.isEmpty {
            prompt += "\n\nRecent logs:\n"
            prompt += entryLines.joined(separator: "\n")
        }
        return prompt
    }

    private static func measurementSummary(for entry: LogEntry) -> String {
        let parts = entry.measurements.sorted { $0.kind.rawValue < $1.kind.rawValue }.map { measurement in
            let value = String(format: "%.2f", measurement.value)
            return "\(measurement.kind.displayName): \(value) \(measurement.unit)"
        }
        return parts.joined(separator: ", ")
    }
}
