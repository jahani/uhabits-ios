import Foundation

struct ScoreSample: Identifiable, Hashable, Codable {
    var id: Date { date }
    var date: Date
    var value: Double

    init(date: Date, value: Double) {
        self.date = date
        self.value = value
    }
}

struct HabitStatistics: Hashable {
    let habit: Habit
    let timeline: [ScoreSample]
    let completions: [Date: Double]
    let asOf: Date
    var calendar: Calendar = Calendar.current

    var currentScore: Double {
        timeline.last?.value ?? 0.0
    }

    var todaysCompletionValue: Double {
        let today = calendar.startOfDay(for: asOf)
        return completions[today] ?? 0.0
    }

    var completionCount: Int {
        completions.values.filter { $0 > 0 }.count
    }

    var expectedCompletionCount: Int {
        habit.schedule.expectedOccurrences(from: habit.createdDate, to: asOf, calendar: calendar)
    }

    var completionRate: Double {
        guard expectedCompletionCount > 0 else { return 0 }
        return Double(completionCount) / Double(expectedCompletionCount)
    }

    var currentStreak: Int {
        computeCurrentStreak()
    }

    var bestStreak: Int {
        computeBestStreak()
    }

    func scoreChange(days: Int) -> Double {
        guard days > 0 else { return 0 }
        let target = calendar.date(byAdding: .day, value: -days, to: calendar.startOfDay(for: asOf)) ?? asOf
        guard let sample = sample(on: target) else { return 0 }
        return currentScore - sample.value
    }

    func sample(on date: Date) -> ScoreSample? {
        let normalized = calendar.startOfDay(for: date)
        return timeline.first { calendar.isDate($0.date, inSameDayAs: normalized) }
    }

    func averageScore(last days: Int) -> Double {
        guard days > 0 else { return currentScore }
        let lowerBound = calendar.date(byAdding: .day, value: -days + 1, to: calendar.startOfDay(for: asOf)) ?? asOf
        let filtered = timeline.filter { sample in
            sample.date >= lowerBound && sample.date <= asOf
        }
        guard !filtered.isEmpty else { return currentScore }
        let total = filtered.reduce(0.0) { $0 + $1.value }
        return total / Double(filtered.count)
    }

    private func computeCurrentStreak() -> Int {
        var streak = 0
        var cursor = calendar.startOfDay(for: asOf)
        let lowerBound = calendar.startOfDay(for: habit.createdDate)

        while cursor >= lowerBound {
            if !habit.schedule.isDue(on: cursor, since: habit.createdDate, calendar: calendar) {
                guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
                cursor = previous
                continue
            }

            let value = completions[cursor] ?? 0
            if value > 0 {
                streak += 1
            } else {
                break
            }

            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streak
    }

    private func computeBestStreak() -> Int {
        var best = 0
        var current = 0
        var cursor = calendar.startOfDay(for: habit.createdDate)
        let end = calendar.startOfDay(for: asOf)

        while cursor <= end {
            if habit.schedule.isDue(on: cursor, since: habit.createdDate, calendar: calendar) {
                if (completions[cursor] ?? 0) > 0 {
                    current += 1
                    best = max(best, current)
                } else {
                    current = 0
                }
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }

        return best
    }
}
