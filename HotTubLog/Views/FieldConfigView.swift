import SwiftUI
import SwiftData

struct FieldConfigView: View {
    @Query(sort: \EntryType.name) private var entryTypes: [EntryType]

    var body: some View {
        List {
            ForEach(entryTypes) { entryType in
                NavigationLink {
                    FieldConfigDetailView(entryType: entryType)
                } label: {
                    HStack {
                        Image(systemName: entryType.iconName)
                            .foregroundColor(Color(hex: entryType.colorHex))
                        Text(entryType.name)
                    }
                }
            }
        }
        .navigationTitle("Field Builder")
    }
}
