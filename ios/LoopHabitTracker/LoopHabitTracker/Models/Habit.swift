import Foundation
import SwiftUI

struct Habit: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var question: String
    var notes: String
    var color: HabitColor
    var schedule: HabitSchedule
    var reminder: HabitReminder?
    var createdDate: Date
    var archived: Bool
    var events: [HabitEvent]
    var targetValue: Double
    var unit: String

    init(
        id: UUID = UUID(),
        name: String,
        question: String = "",
        notes: String = "",
        color: HabitColor = HabitColor.palette.first ?? HabitColor.default,
        schedule: HabitSchedule = .daily,
        reminder: HabitReminder? = nil,
        createdDate: Date = Date(),
        archived: Bool = false,
        events: [HabitEvent] = [],
        targetValue: Double = 1.0,
        unit: String = "times"
    ) {
        self.id = id
        self.name = name
        self.question = question
        self.notes = notes
        self.color = color
        self.schedule = schedule
        self.reminder = reminder
        self.createdDate = createdDate
        self.archived = archived
        self.events = events
        self.targetValue = targetValue
        self.unit = unit
    }

    var displayName: String { name }

    var sortedEvents: [HabitEvent] {
        events.sortedAscending()
    }

    func hasEvent(on date: Date, calendar: Calendar = .current) -> Bool {
        events.containsEvent(on: date, calendar: calendar)
    }

    func completionValue(on date: Date, calendar: Calendar = .current) -> Double {
        events.event(on: date, calendar: calendar)?.value ?? 0.0
    }

    func completionNote(on date: Date, calendar: Calendar = .current) -> String? {
        events.event(on: date, calendar: calendar)?.note
    }

    func statistics(asOf date: Date = Date(), calendar: Calendar = .current) -> HabitStatistics {
        let timeline = scoreTimeline(until: date, calendar: calendar)
        let completions = completionMap(calendar: calendar)
        return HabitStatistics(
            habit: self,
            timeline: timeline,
            completions: completions,
            asOf: date,
            calendar: calendar
        )
    }

    func scoreTimeline(until endDate: Date = Date(), calendar: Calendar = .current) -> [ScoreSample] {
        let normalizedStart = calendar.startOfDay(for: createdDate)
        let normalizedEnd = calendar.startOfDay(for: endDate)
        guard normalizedStart <= normalizedEnd else { return [] }

        var cursor = normalizedStart
        var previousScore = 0.0
        var samples: [ScoreSample] = []

        let completionMap = completionMap(calendar: calendar)
        while cursor <= normalizedEnd {
            let key = calendar.startOfDay(for: cursor)
            let due = schedule.isDue(on: key, since: createdDate, calendar: calendar)
            let checkmark: Double
            if due {
                checkmark = completionMap[key] ?? 0.0
            } else {
                checkmark = previousScore
            }
            let computed = HabitScoreCalculator.compute(
                frequency: schedule.frequency,
                previousScore: previousScore,
                checkmarkValue: checkmark
            )
            samples.append(ScoreSample(date: key, value: computed))
            previousScore = computed
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return samples
    }

    func completionMap(calendar: Calendar = .current) -> [Date: Double] {
        var map: [Date: Double] = [:]
        let normalized = events.map { event -> HabitEvent in
            var copy = event
            copy.date = calendar.startOfDay(for: event.date)
            return copy
        }
        for event in normalized {
            map[event.date] = event.value
        }
        return map
    }

    func toggledCompletion(on date: Date, calendar: Calendar = .current) -> Habit {
        var copy = self
        copy.toggleCompletion(on: date, calendar: calendar)
        return copy
    }

    mutating func toggleCompletion(on date: Date, calendar: Calendar = .current) {
        let normalizedDate = calendar.startOfDay(for: date)
        if let existing = events.event(on: normalizedDate, calendar: calendar) {
            events = events.filter { $0.id != existing.id }
        } else {
            events.append(HabitEvent(date: normalizedDate, value: 1.0))
        }
    }

    mutating func setCompletion(_ isCompleted: Bool, on date: Date, calendar: Calendar = .current) {
        let normalizedDate = calendar.startOfDay(for: date)
        events = events.filter { !calendar.isDate($0.date, inSameDayAs: normalizedDate) }
        if isCompleted {
            events.append(HabitEvent(date: normalizedDate, value: 1.0))
        }
    }

    mutating func updateEvent(on date: Date, note: String?, value: Double = 1.0, calendar: Calendar = .current) {
        let normalizedDate = calendar.startOfDay(for: date)
        if var event = events.event(on: normalizedDate, calendar: calendar) {
            event.note = note
            event.value = value
            events = events.replacing(event)
        } else {
            events.append(HabitEvent(date: normalizedDate, value: value, note: note))
        }
    }
}

struct HabitReminder: Codable, Hashable {
    var isEnabled: Bool
    var time: DateComponents
    var message: String

    init(isEnabled: Bool = false, time: DateComponents = DateComponents(hour: 9, minute: 0), message: String = "") {
        self.isEnabled = isEnabled
        self.time = time
        self.message = message
    }
}

struct HabitColor: Codable, Hashable, Identifiable {
    var id: String { name }
    var name: String
    var hex: String

    init(name: String, hex: String) {
        self.name = name
        self.hex = hex
    }

    var color: Color {
        Color(hex: hex)
    }

    static let `default` = HabitColor(name: "Sky", hex: "4DA1FF")

    static let palette: [HabitColor] = [
        HabitColor(name: "Sky", hex: "4DA1FF"),
        HabitColor(name: "Sunrise", hex: "FFB545"),
        HabitColor(name: "Lime", hex: "74C365"),
        HabitColor(name: "Orchid", hex: "B574FF"),
        HabitColor(name: "Crimson", hex: "FF4F70"),
        HabitColor(name: "Ocean", hex: "1772FF"),
        HabitColor(name: "Slate", hex: "657786"),
        HabitColor(name: "Midnight", hex: "192734"),
        HabitColor(name: "Sunset", hex: "FF8360")
    ]
}
