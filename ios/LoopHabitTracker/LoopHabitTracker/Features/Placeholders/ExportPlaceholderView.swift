import SwiftUI

struct ExportPlaceholderView: View {
    var habit: Habit

    @State private var showingInfo = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Data export", systemImage: "square.and.arrow.up")
                .font(.headline)
            Text("CSV and SQLite exports are not yet wired on iOS. Tap below to see where the export entry points will appear once implemented.")
                .font(.footnote)
                .foregroundColor(.secondary)

            Button {
                showingInfo = true
            } label: {
                Label("Export habit data", systemImage: "doc.badge.plus")
                    .font(.subheadline)
            }
            .buttonStyle(.borderedProminent)
            .tint(habit.color.color)
            .alert("Export roadmap", isPresented: $showingInfo) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("A background worker will serialize your habit entries, notes and scores to CSV and SQLite formats. The files will be shared using the system share sheet.")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(.background))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ExportPlaceholderView(habit: PreviewData.bootstrapHabits.first!)
        .padding()
}
