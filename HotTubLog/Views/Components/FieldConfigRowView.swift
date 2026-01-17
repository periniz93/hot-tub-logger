import SwiftUI
import SwiftData

struct FieldConfigRowView: View {
    @Bindable var config: FieldConfig

    var body: some View {
        Toggle(isOn: $config.enabled) {
            Text(config.fieldKind.displayName)
        }
    }
}
