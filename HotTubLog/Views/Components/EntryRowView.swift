import SwiftUI

struct EntryRowView: View {
    let entry: LogEntry

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(entryColor.opacity(0.2))
                    .frame(width: 36, height: 36)
                Image(systemName: entry.entryType?.iconName ?? "square.and.pencil")
                    .foregroundColor(entryColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.entryType?.name ?? "Entry")
                    .font(.headline)

                Text(dateText)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if !entry.notes.isEmpty {
                    Text(entry.notes)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                let measurementLine = measurementSummary
                if !measurementLine.isEmpty {
                    Text(measurementLine)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var entryColor: Color {
        Color(hex: entry.entryType?.colorHex ?? "999999")
    }

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: entry.timestamp)
    }

    private var measurementSummary: String {
        let parts = entry.measurements.sorted { $0.kind.rawValue < $1.kind.rawValue }.map { measurement in
            let value = String(format: "%.2f", measurement.value)
            return "\(measurement.kind.displayName): \(value) \(measurement.unit)"
        }
        return parts.joined(separator: ", ")
    }
}
