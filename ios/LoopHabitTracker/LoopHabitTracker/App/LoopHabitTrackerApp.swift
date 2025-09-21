import SwiftUI

@main
struct LoopHabitTrackerApp: App {
    @StateObject private var store = HabitStore()

    var body: some Scene {
        WindowGroup {
            HabitListView()
                .environmentObject(store)
                .task {
                    await store.load()
                }
        }
    }
}
