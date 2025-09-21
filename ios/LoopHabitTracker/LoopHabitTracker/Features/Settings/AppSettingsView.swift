import SwiftUI

struct AppSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var use24HourFormat = true
    @State private var weekStartsOn: Weekday = .monday

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("General")) {
                    Toggle("24-hour time", isOn: $use24HourFormat)
                    Picker("First weekday", selection: $weekStartsOn) {
                        ForEach(Weekday.allCases) { day in
                            Text(day.localizedName.capitalized).tag(day)
                        }
                    }
                }

                Section(header: Text("Data"), footer: Text("Backups, imports and cloud sync will be added in a future milestone. This screen keeps the UX entry points documented.")) {
                    Button {
                        // Placeholder: implement backup workflow
                    } label: {
                        Label("Create backup", systemImage: "tray.and.arrow.up")
                    }
                    .disabled(true)

                    Button {
                        // Placeholder: implement restore workflow
                    } label: {
                        Label("Restore from backup", systemImage: "arrow.triangle.2.circlepath")
                    }
                    .disabled(true)
                }

                Section(header: Text("About")) {
                    Link(destination: URL(string: "https://github.com/iSoron/uhabits")!) {
                        Label("Project repository", systemImage: "link")
                    }
                    Link(destination: URL(string: "https://loophabits.org")!) {
                        Label("Official website", systemImage: "safari")
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Loop Habit Tracker is open source software released under the GPLv3 license.")
                        Text("This iOS version is in active development; some Android features are still on the roadmap.")
                            .foregroundColor(.secondary)
                    }
                    .font(.footnote)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    AppSettingsView()
}
