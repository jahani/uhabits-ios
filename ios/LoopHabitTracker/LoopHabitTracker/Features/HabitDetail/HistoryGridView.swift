import SwiftUI

struct HistoryGridView: View {
    let habit: Habit
    var calendar: Calendar = .current
    var range: Int = 56

    private var dates: [Date] {
        let today = calendar.startOfDay(for: Date())
        return (0..<range).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: today)
        }.reversed()
    }

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
            ForEach(dates, id: \.self) { date in
                let completed = habit.hasEvent(on: date, calendar: calendar)
                let due = habit.schedule.isDue(on: date, since: habit.createdDate, calendar: calendar)
                RoundedRectangle(cornerRadius: 6)
                    .fill(color(for: completed, due: due))
                    .frame(height: 24)
                    .overlay(
                        Text(dayLabel(for: date))
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(color(for: completed, due: due).accessibilityTextColor)
                    )
                    .accessibilityLabel(accessibilityLabel(for: date, completed: completed, due: due))
            }
        }
    }

    private func dayLabel(for date: Date) -> String {
        let weekday = Weekday.weekday(for: date, calendar: calendar)
        return weekday.localizedName.prefix(1).uppercased()
    }

    private func color(for completed: Bool, due: Bool) -> Color {
        if completed {
            return habit.color.color
        } else if due {
            return Color(UIColor.tertiarySystemFill)
        } else {
            return Color(UIColor.systemFill).opacity(0.2)
        }
    }

    private func accessibilityLabel(for date: Date, completed: Bool, due: Bool) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: date)
        if completed {
            return "\(dateString): completed"
        } else if due {
            return "\(dateString): missed"
        } else {
            return "\(dateString): rest day"
        }
    }
}

private extension Color {
    var accessibilityTextColor: Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        #if canImport(UIKit)
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        return luminance > 0.6 ? .black : .white
        #else
        return .white
        #endif
    }
}

#Preview {
    HistoryGridView(habit: PreviewData.bootstrapHabits.first!)
        .padding()
}
