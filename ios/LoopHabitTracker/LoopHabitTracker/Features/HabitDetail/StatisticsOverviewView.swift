import SwiftUI

struct StatisticsOverviewView: View {
    let stats: HabitStatistics

    private var values: [StatisticValue] {
        [
            StatisticValue(
                title: "Current streak",
                value: "\(stats.currentStreak) days",
                systemImage: "flame.fill",
                tint: .orange
            ),
            StatisticValue(
                title: "Best streak",
                value: "\(stats.bestStreak) days",
                systemImage: "crown.fill",
                tint: .yellow
            ),
            StatisticValue(
                title: "Completion rate",
                value: String(format: "%.0f%%", stats.completionRate * 100),
                systemImage: "target",
                tint: .blue
            ),
            StatisticValue(
                title: "30-day change",
                value: String(format: "%+.0f%%", stats.scoreChange(days: 30) * 100),
                systemImage: "arrow.up.and.down",
                tint: stats.scoreChange(days: 30) >= 0 ? .green : .red
            ),
            StatisticValue(
                title: "90-day avg",
                value: String(format: "%.0f%%", stats.averageScore(last: 90) * 100),
                systemImage: "waveform.path.ecg",
                tint: .purple
            ),
            StatisticValue(
                title: "Today",
                value: String(format: "%.0f%%", stats.todaysCompletionValue * 100),
                systemImage: "sun.max.fill",
                tint: .pink
            )
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Statistics", systemImage: "chart.bar")
                .font(.headline)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(values) { stat in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: stat.systemImage)
                                .foregroundColor(stat.tint)
                                .font(.title3)
                            Spacer()
                            Text(stat.value)
                                .font(.headline)
                        }
                        Text(stat.title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color(UIColor.secondarySystemBackground)))
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(.background))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

private struct StatisticValue: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let systemImage: String
    let tint: Color
}

#Preview {
    StatisticsOverviewView(stats: PreviewData.bootstrapHabits.first!.statistics())
}
