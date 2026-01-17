import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            LogListView()
                .tabItem {
                    Label("Log", systemImage: "list.bullet.rectangle")
                }

            RemindersView()
                .tabItem {
                    Label("Reminders", systemImage: "bell")
                }

            ExportView()
                .tabItem {
                    Label("Export", systemImage: "square.and.arrow.up")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}
