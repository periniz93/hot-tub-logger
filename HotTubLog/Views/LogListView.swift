import SwiftUI
import SwiftData

struct LogListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LogEntry.timestamp, order: .reverse) private var entries: [LogEntry]
    @Query(sort: \EntryType.name) private var entryTypes: [EntryType]

    @State private var selectedTypeId: UUID?
    @State private var showingAdd = false

    private var filteredEntries: [LogEntry] {
        guard let selectedTypeId else { return entries }
        return entries.filter { $0.entryType?.id == selectedTypeId }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                filterBar

                if filteredEntries.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(filteredEntries) { entry in
                            NavigationLink {
                                EntryDetailView(entry: entry)
                            } label: {
                                EntryRowView(entry: entry)
                            }
                        }
                        .onDelete(perform: deleteEntries)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Hot Tub Log")
            .toolbar {
                Button {
                    showingAdd = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEntryView()
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                EntryTypeChip(
                    title: "All",
                    systemImage: "line.3.horizontal.decrease",
                    color: .primary,
                    isSelected: selectedTypeId == nil
                ) {
                    selectedTypeId = nil
                }

                ForEach(entryTypes) { entryType in
                    EntryTypeChip(
                        title: entryType.name,
                        systemImage: entryType.iconName,
                        color: Color(hex: entryType.colorHex),
                        isSelected: selectedTypeId == entryType.id
                    ) {
                        selectedTypeId = entryType.id
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "drop.triangle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No entries yet")
                .font(.headline)
            Text("Tap + to log a new maintenance task.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 40)
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            let entry = filteredEntries[index]
            modelContext.delete(entry)
        }
        try? modelContext.save()
    }
}
