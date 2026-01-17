import SwiftUI
import SwiftData

struct ExportView: View {
    @Query(sort: \LogEntry.timestamp, order: .reverse) private var entries: [LogEntry]

    @State private var startDate: Date = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
    @State private var endDate: Date = Date()
    @State private var exportURL: URL?
    @State private var alertMessage: String?

    private var filteredEntries: [LogEntry] {
        entries.filter { $0.timestamp >= startDate && $0.timestamp <= endDate }
    }

    private var isRangeValid: Bool {
        startDate <= endDate
    }

    private var canExport: Bool {
        isRangeValid && !filteredEntries.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Date Range") {
                    DatePicker("From", selection: $startDate, displayedComponents: .date)
                    DatePicker("To", selection: $endDate, displayedComponents: .date)
                    Text("Entries: \(filteredEntries.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if !isRangeValid {
                        Text("Start date must be before end date.")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else if filteredEntries.isEmpty {
                        Text("No entries in this range.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Section("Export") {
                    Button("Export CSV") {
                        exportCSV()
                    }
                    .disabled(!canExport)

                    Button("Export PDF") {
                        exportPDF()
                    }
                    .disabled(!canExport)

                    if let exportURL {
                        ShareLink(item: exportURL) {
                            Text("Share Last Export")
                        }
                    }
                }
            }
            .navigationTitle("Export")
            .alert("Export Failed", isPresented: Binding(
                get: { alertMessage != nil },
                set: { _ in alertMessage = nil }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage ?? "")
            }
        }
    }

    private func exportCSV() {
        do {
            exportURL = try ExportService.exportCSV(entries: filteredEntries)
        } catch {
            alertMessage = "Unable to export CSV."
        }
    }

    private func exportPDF() {
        do {
            exportURL = try ExportService.exportPDF(entries: filteredEntries)
        } catch {
            alertMessage = "Unable to export PDF."
        }
    }
}
