import SwiftUI

struct ReminderPlaceholderView: View {
    var reminder: HabitReminder?
    var onUpdate: (HabitReminder?) -> Void

    @State private var showingPlaceholderAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Reminder", systemImage: "bell")
                    .font(.headline)
                Spacer()
                Toggle(isOn: Binding(
                    get: { reminder?.isEnabled ?? false },
                    set: { isOn in
                        var updated = reminder ?? HabitReminder()
                        updated.isEnabled = isOn
                        onUpdate(isOn ? updated : nil)
                    }
                )) {
                    Text("Enabled")
                }
                .labelsHidden()
            }

            Text("Notification scheduling is not yet implemented on iOS. This section keeps your configuration so it can be wired to the native notification APIs in a future update.")
                .font(.footnote)
                .foregroundColor(.secondary)

            Button {
                showingPlaceholderAlert = true
            } label: {
                Label("Configure reminder", systemImage: "slider.horizontal.3")
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)
            .alert("Coming soon", isPresented: $showingPlaceholderAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Reminder time picker and notification scheduling will be implemented once the iOS notification stack is in place.")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(.background))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ReminderPlaceholderView(reminder: HabitReminder(isEnabled: true)) { _ in }
        .padding()
}
