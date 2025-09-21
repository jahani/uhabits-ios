import SwiftUI

struct ScoreRingView: View {
    var color: Color
    var progress: Double
    var isCompleted: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: CGFloat(min(max(progress, 0.0), 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .foregroundColor(color)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: progress)

                Image(systemName: isCompleted ? "checkmark" : "plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isCompleted ? .white : color)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(isCompleted ? color : color.opacity(0.15))
                    )
            }
            .frame(width: 54, height: 54)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isCompleted ? "Mark as missed" : "Mark as completed")
    }
}

#Preview {
    HStack(spacing: 24) {
        ScoreRingView(color: .blue, progress: 0.8, isCompleted: true, action: {})
        ScoreRingView(color: .orange, progress: 0.3, isCompleted: false, action: {})
    }
    .padding()
}
