import SwiftUI
import SwiftData
import PhotosUI

struct AddEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \EntryType.name) private var entryTypes: [EntryType]

    let entryToEdit: LogEntry?

    @State private var selectedTypeId: UUID?
    @State private var timestamp = Date()
    @State private var notes = ""
    @State private var measurementInputs: [FieldKind: String] = [:]

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoImage: UIImage?
    @State private var photoUpdated = false
    @State private var suppressTypeReset = false

    init(entryToEdit: LogEntry? = nil) {
        self.entryToEdit = entryToEdit
    }

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
            .navigationTitle(entryToEdit == nil ? "New Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(entryToEdit == nil ? "Save" : "Update") { saveEntry() }
                }
            }
            .onAppear {
                if let entryToEdit {
                    populate(from: entryToEdit)
                }
                if selectedTypeId == nil {
                    selectedTypeId = entryTypes.first?.id
                }
            }
            .onChange(of: selectedTypeId) { _ in
                guard !suppressTypeReset else { return }
                measurementInputs.removeAll()
            }
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    guard let data = try? await newItem?.loadTransferable(type: Data.self),
                          let image = UIImage(data: data) else {
                        return
                    }
                    photoImage = image
                    photoUpdated = true
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

                Button("Remove Photo") {
                    photoImage = nil
                    selectedPhotoItem = nil
                    photoUpdated = true
                }
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

    private func populate(from entry: LogEntry) {
        suppressTypeReset = true
        selectedTypeId = entry.entryType?.id
        timestamp = entry.timestamp
        notes = entry.notes
        measurementInputs = [:]
        for measurement in entry.measurements {
            let fieldKind = FieldKind(rawValue: measurement.kind.rawValue) ?? .ph
            measurementInputs[fieldKind] = String(format: "%.2f", measurement.value)
        }

        if let filename = entry.photoFilename {
            photoImage = PhotoStore.load(filename: filename)
        }
        photoUpdated = false
        suppressTypeReset = false
    }

    private func saveEntry() {
        guard let entryType = selectedEntryType else { return }

        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        if let entryToEdit {
            entryToEdit.timestamp = timestamp
            entryToEdit.notes = trimmedNotes
            entryToEdit.entryType = entryType

            if photoUpdated {
                if let photoImage, let filename = try? PhotoStore.save(image: photoImage) {
                    entryToEdit.photoFilename = filename
                } else {
                    entryToEdit.photoFilename = nil
                }
            }

            for measurement in entryToEdit.measurements {
                modelContext.delete(measurement)
            }
            entryToEdit.measurements.removeAll()
            appendMeasurements(to: entryToEdit)
        } else {
            let entry = LogEntry(
                timestamp: timestamp,
                notes: trimmedNotes,
                entryType: entryType
            )

            if let photoImage, let filename = try? PhotoStore.save(image: photoImage) {
                entry.photoFilename = filename
            }

            appendMeasurements(to: entry)
            modelContext.insert(entry)
        }

        try? modelContext.save()
        dismiss()
    }

    private func appendMeasurements(to entry: LogEntry) {
        for kind in MeasurementKind.allCases {
            let fieldKind = FieldKind(rawValue: kind.rawValue) ?? .ph
            guard let input = measurementInputs[fieldKind],
                  let value = Double(input.replacingOccurrences(of: ",", with: ".")) else {
                continue
            }
            let measurement = Measurement(kind: kind, value: value, unit: kind.defaultUnit, logEntry: entry)
            entry.measurements.append(measurement)
        }
    }
}
