import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var form: HabitFormModel
    var onCreate: (Habit) -> Void

    init(habit: Habit? = nil, onCreate: @escaping (Habit) -> Void) {
        self._form = State(initialValue: HabitFormModel(habit: habit))
        self.onCreate = onCreate
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Details")) {
                    TextField("Name", text: $form.name)
                        .textInputAutocapitalization(.words)
                    TextField("Question", text: $form.question)
                        .textInputAutocapitalization(.sentences)
                    TextField("Notes", text: $form.notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section(header: Text("Schedule")) {
                    SchedulePickerView(schedule: $form.schedule)
                }

                Section(header: Text("Color")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(HabitColor.palette) { color in
                                Button {
                                    form.color = color
                                } label: {
                                    Circle()
                                        .fill(color.color)
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary.opacity(form.color == color ? 0.6 : 0.1), lineWidth: form.color == color ? 4 : 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section(header: Text("Goal")) {
                    Stepper(value: $form.targetValue, in: 1...100, step: 1) {
                        Text("Target: \(Int(form.targetValue)) \(form.unit)")
                    }
                    TextField("Unit", text: $form.unit)
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationTitle(form.isEditing ? "Edit habit" : "New habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(form.isEditing ? "Save" : "Create") {
                        let habit = form.makeHabit()
                        onCreate(habit)
                        dismiss()
                    }
                    .disabled(!form.isValid)
                }
            }
        }
    }
}

private struct HabitFormModel {
    var id: UUID?
    var name: String
    var question: String
    var notes: String
    var color: HabitColor
    var schedule: HabitSchedule
    var targetValue: Double
    var unit: String
    var createdDate: Date
    var reminder: HabitReminder?
    var archived: Bool
    var events: [HabitEvent]

    init(habit: Habit?) {
        if let habit {
            self.id = habit.id
            self.name = habit.name
            self.question = habit.question
            self.notes = habit.notes
            self.color = habit.color
            self.schedule = habit.schedule
            self.targetValue = habit.targetValue
            self.unit = habit.unit
            self.createdDate = habit.createdDate
            self.reminder = habit.reminder
            self.archived = habit.archived
            self.events = habit.events
        } else {
            self.id = nil
            self.name = ""
            self.question = ""
            self.notes = ""
            self.color = HabitColor.palette.first ?? HabitColor.default
            self.schedule = .daily
            self.targetValue = 1
            self.unit = "time"
            self.createdDate = Date()
            self.reminder = nil
            self.archived = false
            self.events = []
        }
    }

    var isEditing: Bool { id != nil }

    var isValid: Bool { !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    func makeHabit() -> Habit {
        Habit(
            id: id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            question: question,
            notes: notes,
            color: color,
            schedule: schedule,
            reminder: reminder,
            createdDate: createdDate,
            archived: archived,
            events: events,
            targetValue: targetValue,
            unit: unit
        )
    }
}

#Preview {
    AddHabitView { _ in }
}
