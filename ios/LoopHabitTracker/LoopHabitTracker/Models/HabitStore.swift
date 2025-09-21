import Foundation
import Combine

@MainActor
final class HabitStore: ObservableObject {
    @Published private(set) var habits: [Habit]
    @Published var lastError: HabitPersistence.PersistenceError?

    private let persistence: HabitPersistence
    private var cancellables: Set<AnyCancellable> = []

    init(habits: [Habit] = [], persistence: HabitPersistence = HabitPersistence()) {
        self.habits = habits
        self.persistence = persistence

        $habits
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] habits in
                Task { await self?.persist(habits: habits) }
            }
            .store(in: &cancellables)
    }

    var activeHabits: [Habit] {
        habits.filter { !$0.archived }
    }

    var archivedHabits: [Habit] {
        habits.filter { $0.archived }
    }

    func load() async {
        do {
            let loaded = try await persistence.load()
            habits = loaded
        } catch let error as HabitPersistence.PersistenceError {
            lastError = error
        } catch {
            lastError = .failedToLoad(error.localizedDescription)
        }
    }

    func persist(habits: [Habit]) async {
        do {
            try await persistence.save(habits)
        } catch let error as HabitPersistence.PersistenceError {
            lastError = error
        } catch {
            lastError = .failedToSave(error.localizedDescription)
        }
    }

    func addHabit(_ habit: Habit) {
        habits.append(habit)
    }

    func updateHabit(_ habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[index] = habit
    }

    func removeHabits(at offsets: IndexSet, inArchivedSection: Bool = false) {
        var filtered = inArchivedSection ? archivedHabits : activeHabits
        offsets.sorted(by: >).forEach { index in
            guard filtered.indices.contains(index) else { return }
            let habit = filtered[index]
            if let originalIndex = habits.firstIndex(where: { $0.id == habit.id }) {
                habits.remove(at: originalIndex)
            }
        }
    }

    func toggleCompletion(for habitID: UUID, on date: Date, calendar: Calendar = .current) {
        guard let index = habits.firstIndex(where: { $0.id == habitID }) else { return }
        habits[index].toggleCompletion(on: date, calendar: calendar)
    }

    func setArchived(_ isArchived: Bool, habitID: UUID) {
        guard let index = habits.firstIndex(where: { $0.id == habitID }) else { return }
        habits[index].archived = isArchived
    }

    func reorder(fromOffsets: IndexSet, toOffset: Int, archived: Bool) {
        var filteredIDs: [UUID] = (archived ? archivedHabits : activeHabits).map { $0.id }
        filteredIDs.move(fromOffsets: fromOffsets, toOffset: toOffset)

        let newOrder = filteredIDs + (archived ? activeHabits : archivedHabits).map { $0.id }
        habits.sort { lhs, rhs in
            guard let leftIndex = newOrder.firstIndex(of: lhs.id) else { return false }
            guard let rightIndex = newOrder.firstIndex(of: rhs.id) else { return true }
            return leftIndex < rightIndex
        }
    }
}
