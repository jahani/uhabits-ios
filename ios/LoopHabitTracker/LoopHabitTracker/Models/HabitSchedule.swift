import Foundation

enum Weekday: Int, CaseIterable, Codable, Identifiable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    var id: Int { rawValue }

    var calendarIndex: Int {
        rawValue
    }

    var localizedName: String {
        let calendar = Calendar.current
        let symbols = calendar.shortWeekdaySymbols
        let index = (rawValue - calendar.firstWeekday + 7) % 7
        if symbols.indices.contains(index) {
            return symbols[index]
        } else {
            return String(describing: self).capitalized
        }
    }

    static func weekday(for date: Date, calendar: Calendar = .current) -> Weekday {
        let weekdayValue = calendar.component(.weekday, from: date)
        return Weekday(rawValue: weekdayValue) ?? .monday
    }
}

enum HabitSchedule: Hashable {
    case daily
    case weekly(days: Set<Weekday>)
    case timesPerWeek(Int)
    case everyXDays(Int)
    case custom(description: String)

    var frequency: Double {
        switch self {
        case .daily:
            return 1.0
        case .weekly(let days):
            return Double(max(days.count, 1)) / 7.0
        case .timesPerWeek(let count):
            return Double(max(count, 1)) / 7.0
        case .everyXDays(let interval):
            guard interval > 0 else { return 1.0 }
            return 1.0 / Double(interval)
        case .custom:
            return 1.0
        }
    }

    var description: String {
        switch self {
        case .daily:
            return NSLocalizedString("Every day", comment: "Daily schedule")
        case .weekly(let days):
            let sorted = days.sorted { $0.rawValue < $1.rawValue }
            let label = sorted.map { $0.localizedName }.joined(separator: ", ")
            return label.isEmpty ? NSLocalizedString("Weekly", comment: "Weekly schedule fallback") : label
        case .timesPerWeek(let times):
            return String(format: NSLocalizedString("%d times per week", comment: "Times per week"), times)
        case .everyXDays(let interval):
            if interval == 1 {
                return NSLocalizedString("Every day", comment: "Interval schedule fallback")
            }
            return String(format: NSLocalizedString("Every %d days", comment: "Interval schedule"), interval)
        case .custom(let description):
            return description
        }
    }

    func isDue(on date: Date, since startDate: Date, calendar: Calendar = .current) -> Bool {
        switch self {
        case .daily, .timesPerWeek:
            return true
        case .weekly(let days):
            let weekday = Weekday.weekday(for: date, calendar: calendar)
            return days.contains(weekday)
        case .everyXDays(let interval):
            guard interval > 0 else { return true }
            let start = calendar.startOfDay(for: startDate)
            let target = calendar.startOfDay(for: date)
            guard let days = calendar.dateComponents([.day], from: start, to: target).day else { return false }
            return days % interval == 0
        case .custom:
            return true
        }
    }

    func expectedOccurrences(from startDate: Date, to endDate: Date, calendar: Calendar = .current) -> Int {
        guard startDate <= endDate else { return 0 }
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        var cursor = start
        var occurrences = 0
        while cursor <= end {
            if isDue(on: cursor, since: startDate, calendar: calendar) {
                occurrences += 1
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return occurrences
    }
}

extension HabitSchedule: Codable {
    private enum CodingKeys: String, CodingKey {
        case type
        case payload
    }

    private enum ScheduleType: String, Codable {
        case daily
        case weekly
        case timesPerWeek
        case everyXDays
        case custom
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .daily:
            try container.encode(ScheduleType.daily, forKey: .type)
        case .weekly(let days):
            try container.encode(ScheduleType.weekly, forKey: .type)
            try container.encode(Array(days), forKey: .payload)
        case .timesPerWeek(let value):
            try container.encode(ScheduleType.timesPerWeek, forKey: .type)
            try container.encode(value, forKey: .payload)
        case .everyXDays(let value):
            try container.encode(ScheduleType.everyXDays, forKey: .type)
            try container.encode(value, forKey: .payload)
        case .custom(let description):
            try container.encode(ScheduleType.custom, forKey: .type)
            try container.encode(description, forKey: .payload)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ScheduleType.self, forKey: .type)
        switch type {
        case .daily:
            self = .daily
        case .weekly:
            let days = try container.decode([Weekday].self, forKey: .payload)
            self = .weekly(days: Set(days))
        case .timesPerWeek:
            let value = try container.decode(Int.self, forKey: .payload)
            self = .timesPerWeek(value)
        case .everyXDays:
            let value = try container.decode(Int.self, forKey: .payload)
            self = .everyXDays(value)
        case .custom:
            let description = try container.decode(String.self, forKey: .payload)
            self = .custom(description: description)
        }
    }
}
