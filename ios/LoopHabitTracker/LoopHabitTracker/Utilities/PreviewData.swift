import Foundation

enum PreviewData {
    static var bootstrapHabits: [Habit] {
        let calendar = Calendar.current
        var morningRoutine = Habit(
            name: "Morning run",
            question: "Did you complete your morning run?",
            notes: "Run at least 3km around the park.",
            color: HabitColor(name: "Sky", hex: "4DA1FF"),
            schedule: .timesPerWeek(4),
            createdDate: calendar.date(byAdding: .day, value: -120, to: Date()) ?? Date()
        )

        var meditation = Habit(
            name: "Meditation",
            question: "Did you meditate today?",
            notes: "10 minutes mindful breathing.",
            color: HabitColor(name: "Orchid", hex: "B574FF"),
            schedule: .daily,
            createdDate: calendar.date(byAdding: .day, value: -60, to: Date()) ?? Date()
        )

        var water = Habit(
            name: "Drink Water",
            question: "Did you drink 2L of water?",
            notes: "Track daily hydration.",
            color: HabitColor(name: "Lime", hex: "74C365"),
            schedule: .everyXDays(1),
            createdDate: calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        )

        // Populate sample events
        for offset in stride(from: 0, through: 60, by: 1) {
            if offset % 2 == 0 {
                if let date = calendar.date(byAdding: .day, value: -offset, to: Date()) {
                    morningRoutine.events.append(HabitEvent(date: date, value: 1.0))
                }
            }
        }

        for offset in stride(from: 0, through: 45, by: 1) {
            if offset % 3 != 0, let date = calendar.date(byAdding: .day, value: -offset, to: Date()) {
                meditation.events.append(HabitEvent(date: date, value: 1.0))
            }
        }

        for offset in stride(from: 0, through: 25, by: 1) {
            if offset % 2 == 0, let date = calendar.date(byAdding: .day, value: -offset, to: Date()) {
                water.events.append(HabitEvent(date: date, value: 1.0))
            }
        }

        return [morningRoutine, meditation, water]
    }
}
