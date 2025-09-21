import SwiftUI

struct SchedulePickerView: View {
    @Binding var schedule: HabitSchedule

    @State private var selectedOption: Option
    @State private var timesPerWeek: Int
    @State private var intervalDays: Int
    @State private var selectedDays: Set<Weekday>
    @State private var customDescription: String

    init(schedule: Binding<HabitSchedule>) {
        _schedule = schedule
        let option = Option(schedule: schedule.wrappedValue)
        _selectedOption = State(initialValue: option)
        switch schedule.wrappedValue {
        case .daily:
            _timesPerWeek = State(initialValue: 3)
            _intervalDays = State(initialValue: 1)
            _selectedDays = State(initialValue: [])
            _customDescription = State(initialValue: "")
        case .timesPerWeek(let count):
            _timesPerWeek = State(initialValue: count)
            _intervalDays = State(initialValue: 1)
            _selectedDays = State(initialValue: [])
            _customDescription = State(initialValue: "")
        case .weekly(let days):
            _timesPerWeek = State(initialValue: max(days.count, 1))
            _intervalDays = State(initialValue: 1)
            _selectedDays = State(initialValue: days)
            _customDescription = State(initialValue: "")
        case .everyXDays(let interval):
            _timesPerWeek = State(initialValue: 3)
            _intervalDays = State(initialValue: max(interval, 1))
            _selectedDays = State(initialValue: [])
            _customDescription = State(initialValue: "")
        case .custom(let description):
            _timesPerWeek = State(initialValue: 3)
            _intervalDays = State(initialValue: 1)
            _selectedDays = State(initialValue: [])
            _customDescription = State(initialValue: description)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Schedule", selection: $selectedOption) {
                ForEach(Option.allCases) { option in
                    Text(option.label).tag(option)
                }
            }
            .pickerStyle(.segmented)

            switch selectedOption {
            case .daily:
                Text("Repeat every day.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            case .timesPerWeek:
                Stepper(value: $timesPerWeek, in: 1...7) {
                    Text("\(timesPerWeek) times per week")
                }
            case .weekly:
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pick the days of the week")
                        .font(.subheadline)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                        ForEach(Weekday.allCases) { day in
                            Button {
                                if selectedDays.contains(day) {
                                    selectedDays.remove(day)
                                } else {
                                    selectedDays.insert(day)
                                }
                            } label: {
                                Text(day.localizedName)
                                    .font(.caption)
                                    .padding(.vertical, 6)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedDays.contains(day) ? Color.accentColor.opacity(0.25) : Color(UIColor.secondarySystemBackground))
                                    )
                            }
                        }
                    }
                }
            case .everyXDays:
                Stepper(value: $intervalDays, in: 1...30) {
                    Text(intervalDays == 1 ? "Every day" : "Every \(intervalDays) days")
                }
            case .custom:
                TextField("Describe your schedule", text: $customDescription)
                    .textInputAutocapitalization(.sentences)
            }
        }
        .onChange(of: selectedOption, perform: updateSchedule)
        .onChange(of: timesPerWeek) { _ in updateSchedule(selectedOption) }
        .onChange(of: intervalDays) { _ in updateSchedule(selectedOption) }
        .onChange(of: selectedDays) { _ in updateSchedule(selectedOption) }
        .onChange(of: customDescription) { _ in updateSchedule(selectedOption) }
    }

    private func updateSchedule(_ option: Option) {
        switch option {
        case .daily:
            schedule = .daily
        case .timesPerWeek:
            schedule = .timesPerWeek(timesPerWeek)
        case .weekly:
            if selectedDays.isEmpty {
                schedule = .weekly(days: [.monday, .wednesday, .friday])
            } else {
                schedule = .weekly(days: selectedDays)
            }
        case .everyXDays:
            schedule = .everyXDays(intervalDays)
        case .custom:
            schedule = .custom(description: customDescription.isEmpty ? "Custom schedule" : customDescription)
        }
    }

    private enum Option: String, CaseIterable, Identifiable {
        case daily
        case timesPerWeek
        case weekly
        case everyXDays
        case custom

        var id: String { rawValue }

        init(schedule: HabitSchedule) {
            switch schedule {
            case .daily:
                self = .daily
            case .timesPerWeek:
                self = .timesPerWeek
            case .weekly:
                self = .weekly
            case .everyXDays:
                self = .everyXDays
            case .custom:
                self = .custom
            }
        }

        var label: String {
            switch self {
            case .daily:
                return "Daily"
            case .timesPerWeek:
                return "Weekly quota"
            case .weekly:
                return "Specific days"
            case .everyXDays:
                return "Interval"
            case .custom:
                return "Custom"
            }
        }
    }
}

#Preview {
    SchedulePickerView(schedule: .constant(.timesPerWeek(3)))
        .padding()
}
