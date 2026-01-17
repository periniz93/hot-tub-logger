import SwiftUI
import SwiftData
import PhotosUI

struct AddEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \EntryType.name) private var entryTypes: [EntryType]

    @State private var selectedTypeId: UUID?
    @State private var timestamp = Date()
    @State private var notes = ""
    @State private var measurementInputs: [FieldKind: String] = [:]

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoImage: UIImage?

    var body: some View {
        NavigationStack {
            Form {
                Section("Entry Type") {
                    Picker("Type", selection: $selectedTypeId) {
                        ForEach(entryTypes) { entryType in
                            Text(entryType.name)
                                .tag(Optional(entryType.id))
                        }
                    }
                }

                Section("When") {
                    DatePicker("Date", selection: $timestamp)
                }

                if let entryType = selectedEntryType {
                    let enabledFields = entryType.fieldConfigs
                        .filter { $0.enabled }
                        .sorted { $0.order < $1.order }

                    ForEach(enabledFields, id: \.id) { config in
                        if let measurementKind = config.fieldKind.measurementKind {
                            measurementField(kind: measurementKind)
                        } else if config.fieldKind == .notes {
                            notesField
                        } else if config.fieldKind == .photo {
                            photoField
                        }
                    }
                }
            }
            .navigationTitle("New Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveEntry() }
                }
            }
            .onAppear {
                if selectedTypeId == nil {
                    selectedTypeId = entryTypes.first?.id
                }
            }
            .onChange(of: selectedTypeId) { _ in
                measurementInputs.removeAll()
                notes = ""
                selectedPhotoItem = nil
                photoImage = nil
            }
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    guard let data = try? await newItem?.loadTransferable(type: Data.self),
                          let image = UIImage(data: data) else {
                        return
                    }
                    photoImage = image
                }
            }
        }
    }

    private var selectedEntryType: EntryType? {
        entryTypes.first { $0.id == selectedTypeId }
    }

    private func measurementField(kind: MeasurementKind) -> some View {
        Section(kind.displayName) {
            HStack {
                TextField("Value", text: binding(for: kind))
                    .keyboardType(.decimalPad)
                Text(kind.defaultUnit)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var notesField: some View {
        Section("Notes") {
            TextEditor(text: $notes)
                .frame(minHeight: 80)
        }
    }

    private var photoField: some View {
        Section("Photo") {
            if let photoImage {
                Image(uiImage: photoImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 220)
            }

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Text(photoImage == nil ? "Add Photo" : "Replace Photo")
            }
        }
    }

    private func binding(for kind: MeasurementKind) -> Binding<String> {
        Binding(
            get: { measurementInputs[FieldKind(rawValue: kind.rawValue) ?? .ph] ?? "" },
            set: { measurementInputs[FieldKind(rawValue: kind.rawValue) ?? .ph] = $0 }
        )
    }

    private func saveEntry() {
        guard let entryType = selectedEntryType else { return }

        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let entry = LogEntry(
            timestamp: timestamp,
            notes: trimmedNotes,
            entryType: entryType
        )

        if let photoImage, let filename = try? PhotoStore.save(image: photoImage) {
            entry.photoFilename = filename
        }

        for kind in MeasurementKind.allCases {
            let fieldKind = FieldKind(rawValue: kind.rawValue) ?? .ph
            guard let input = measurementInputs[fieldKind],
                  let value = Double(input.replacingOccurrences(of: ",", with: ".")) else {
                continue
            }
            let measurement = Measurement(kind: kind, value: value, unit: kind.defaultUnit, logEntry: entry)
            entry.measurements.append(measurement)
        }

        modelContext.insert(entry)
        try? modelContext.save()
        dismiss()
    }
}
