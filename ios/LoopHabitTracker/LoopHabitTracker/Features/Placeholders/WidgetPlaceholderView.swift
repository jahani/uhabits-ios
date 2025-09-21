import SwiftUI

struct WidgetPlaceholderView: View {
    @State private var showingInfo = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Widgets", systemImage: "square.grid.2x2")
                .font(.headline)
            Text("Home screen and lock screen widgets will arrive soon. This placeholder reserves the layout slot and documents the intended design hooks.")
                .font(.footnote)
                .foregroundColor(.secondary)

            Button {
                showingInfo = true
            } label: {
                Label("Preview widget designs", systemImage: "eye")
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)
            .alert("Widget backlog", isPresented: $showingInfo) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Interactive widget timelines will mirror your daily check-ins and scores. Implementation is pending the WidgetKit data bridge.")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(.background))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    WidgetPlaceholderView()
        .padding()
}
