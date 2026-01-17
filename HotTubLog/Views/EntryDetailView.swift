import SwiftUI

struct EntryDetailView: View {
    let entry: LogEntry

    @State private var showingEdit = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                measurementsSection
                notesSection
                photoSection
            }
            .padding()
        }
        .navigationTitle(entry.entryType?.name ?? "Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Edit") {
                showingEdit = true
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddEntryView(entryToEdit: entry)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(entryColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: entry.entryType?.iconName ?? "square.and.pencil")
                    .foregroundColor(entryColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.entryType?.name ?? "Entry")
                    .font(.headline)
                Text(dateText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }

    private var measurementsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if entry.measurements.isEmpty {
                EmptyView()
            } else {
                Text("Measurements")
                    .font(.headline)
                ForEach(entry.measurements.sorted(by: { $0.kind.rawValue < $1.kind.rawValue })) { measurement in
                    HStack {
                        Text(measurement.kind.displayName)
                        Spacer()
                        Text(String(format: "%.2f", measurement.value))
                        Text(measurement.unit)
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                }
            }
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if entry.notes.isEmpty {
                EmptyView()
            } else {
                Text("Notes")
                    .font(.headline)
                Text(entry.notes)
                    .font(.body)
            }
        }
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let filename = entry.photoFilename,
               let image = PhotoStore.load(filename: filename) {
                Text("Photo")
                    .font(.headline)
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                EmptyView()
            }
        }
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
}
