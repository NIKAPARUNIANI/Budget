import SwiftUI
import SwiftData

@main
struct MyBudgetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Expense.self)
    }
}