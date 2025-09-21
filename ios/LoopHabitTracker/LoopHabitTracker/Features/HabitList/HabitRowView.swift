import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let today: Date
    let onTap: () -> Void
    let toggleCompletion: () -> Void

    private var stats: HabitStatistics {
        habit.statistics(asOf: today)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ScoreRingView(
                    color: habit.color.color,
                    progress: stats.currentScore,
                    isCompleted: habit.hasEvent(on: today)
                ) {
                    toggleCompletion()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(habit.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    if !habit.question.isEmpty {
                        Text(habit.question)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }

                    HStack(spacing: 12) {
                        Label {
                            Text("\(Int(stats.currentScore * 100))%")
                        } icon: {
                            Image(systemName: "chart.bar.fill")
                                .foregroundStyle(habit.color.color)
                        }
                        .font(.caption)

                        Label {
                            Text("Streak: \(stats.currentStreak)")
                        } icon: {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.orange)
                        }
                        .font(.caption)
                    }
                }
                Spacer()
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HabitRowView(
        habit: PreviewData.bootstrapHabits.first!,
        today: Date(),
        onTap: {},
        toggleCompletion: {}
    )
    .environmentObject(HabitStore(habits: PreviewData.bootstrapHabits))
}
