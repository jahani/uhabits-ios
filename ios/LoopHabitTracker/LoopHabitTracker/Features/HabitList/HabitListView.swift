import SwiftUI

struct HabitListView: View {
    @EnvironmentObject private var store: HabitStore
    @State private var showingAddHabit = false
    @State private var showingSettings = false
    @State private var selectedHabit: Habit?

    private var today: Date { Date() }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView
                content
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add habit")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView { newHabit in
                    store.addHabit(newHabit)
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(item: $selectedHabit) { habit in
                HabitDetailView(habit: habit) { updated in
                    store.updateHabit(updated)
                }
                .presentationDetents([.large])
            }
            .sheet(isPresented: $showingSettings) {
                AppSettingsView()
            }
            .alert(item: Binding(
                get: {
                    store.lastError.map { PersistenceAlertContext(error: $0) }
                },
                set: { _ in }
            )) { context in
                Alert(
                    title: Text("Persistence error"),
                    message: Text(context.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color(UIColor.systemBackground), Color(UIColor.secondarySystemBackground)]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var content: some View {
        if store.activeHabits.isEmpty && store.archivedHabits.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                Text("No habits yet")
                    .font(.headline)
                Text("Tap the + button to create your first habit.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
        } else {
            List {
                if !store.activeHabits.isEmpty {
                    Section(header: Text("Active")) {
                        ForEach(store.activeHabits) { habit in
                            HabitRowView(habit: habit, today: today) {
                                selectedHabit = habit
                            } toggleCompletion: {
                                store.toggleCompletion(for: habit.id, on: today)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.setArchived(true, habitID: habit.id)
                                } label: {
                                    Label("Archive", systemImage: "archivebox")
                                }
                            }
                        }
                        .onDelete { offsets in
                            store.removeHabits(at: offsets)
                        }
                        .onMove { indices, newOffset in
                            store.reorder(fromOffsets: indices, toOffset: newOffset, archived: false)
                        }
                    }
                }

                if !store.archivedHabits.isEmpty {
                    Section(header: Text("Archived")) {
                        ForEach(store.archivedHabits) { habit in
                            HabitRowView(habit: habit, today: today) {
                                selectedHabit = habit
                            } toggleCompletion: {
                                store.toggleCompletion(for: habit.id, on: today)
                            }
                            .swipeActions(edge: .trailing) {
                                Button {
                                    store.setArchived(false, habitID: habit.id)
                                } label: {
                                    Label("Activate", systemImage: "arrow.uturn.backward")
                                }
                            }
                        }
                        .onDelete { offsets in
                            store.removeHabits(at: offsets, inArchivedSection: true)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
        }
    }
}

private struct PersistenceAlertContext: Identifiable {
    var id = UUID()
    let message: String

    init(error: HabitPersistence.PersistenceError) {
        message = error.localizedDescription
    }
}

#Preview {
    HabitListView()
        .environmentObject(HabitStore(habits: PreviewData.bootstrapHabits))
}
