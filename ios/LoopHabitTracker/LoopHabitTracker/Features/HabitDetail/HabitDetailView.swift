import SwiftUI

struct HabitDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var habit: Habit
    let onSave: (Habit) -> Void

    private var calendar: Calendar { Calendar.current }
    private var today: Date { Date() }
    private var stats: HabitStatistics { habit.statistics(asOf: today, calendar: calendar) }

    init(habit: Habit, onSave: @escaping (Habit) -> Void) {
        self._habit = State(initialValue: habit)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    overview
                    statisticsSection
                    scoreChartSection
                    historySection
                    remindersSection
                    exportSection
                    widgetsSection
                    notesSection
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(habit.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onSave(habit)
                        dismiss()
                    }
                }
            }
        }
    }

    private var overview: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 16) {
                ScoreRingView(
                    color: habit.color.color,
                    progress: stats.currentScore,
                    isCompleted: habit.hasEvent(on: today)
                ) {
                    habit.toggleCompletion(on: today)
                    onSave(habit)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(habit.displayName)
                        .font(.title2.weight(.semibold))
                    Text(habit.schedule.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Current score \(Int(stats.currentScore * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if !habit.question.isEmpty {
                Text(habit.question)
                    .font(.body)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(.background))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    private var statisticsSection: some View {
        StatisticsOverviewView(stats: stats)
    }

    private var scoreChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Habit strength", systemImage: "chart.xyaxis.line")
                    .font(.headline)
                Spacer()
                Text("Last 90 days")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            ScoreChartView(samples: stats.timeline)
                .frame(height: 220)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(.background))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Recent history", systemImage: "calendar")
                .font(.headline)
            HistoryGridView(habit: habit, calendar: calendar)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(.background))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    private var remindersSection: some View {
        ReminderPlaceholderView(reminder: habit.reminder) { newReminder in
            habit.reminder = newReminder
            onSave(habit)
        }
    }

    private var exportSection: some View {
        ExportPlaceholderView(habit: habit)
    }

    private var widgetsSection: some View {
        WidgetPlaceholderView()
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Notes", systemImage: "square.and.pencil")
                .font(.headline)
            TextEditor(text: Binding(
                get: { habit.notes },
                set: {
                    habit.notes = $0
                    onSave(habit)
                }
            ))
            .frame(minHeight: 120)
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.secondarySystemBackground)))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(.background))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    HabitDetailView(habit: PreviewData.bootstrapHabits.first!) { _ in }
}
