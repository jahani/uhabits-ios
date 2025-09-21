import Foundation

struct HabitEvent: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var value: Double
    var note: String?
    var createdAt: Date

    init(id: UUID = UUID(), date: Date, value: Double = 1.0, note: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.date = date
        self.value = value
        self.note = note
        self.createdAt = createdAt
    }
}

extension Array where Element == HabitEvent {
    func event(on date: Date, calendar: Calendar = .current) -> HabitEvent? {
        let normalized = calendar.startOfDay(for: date)
        return first { calendar.isDate($0.date, inSameDayAs: normalized) }
    }

    func containsEvent(on date: Date, calendar: Calendar = .current) -> Bool {
        event(on: date, calendar: calendar) != nil
    }

    func removingEvent(on date: Date, calendar: Calendar = .current) -> [HabitEvent] {
        let normalized = calendar.startOfDay(for: date)
        return filter { !calendar.isDate($0.date, inSameDayAs: normalized) }
    }

    func replacing(_ event: HabitEvent) -> [HabitEvent] {
        map { $0.id == event.id ? event : $0 }
    }

    func sortedAscending() -> [HabitEvent] {
        sorted { lhs, rhs in lhs.date < rhs.date }
    }
}
