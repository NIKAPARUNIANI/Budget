import SwiftUI
import SwiftData

class ExpenseViewModel: ObservableObject {
    @Published var selectedCategory: Category? = nil
    @Published var isShowingAddExpense: Bool = false

    func filteredExpenses(from expenses: [Expense]) -> [Expense] {
        if let category = selectedCategory {
            return expenses.filter { $0.category == category }
        }
        return expenses
    }

    func totalAmount(for expenses: [Expense]) -> Double {
        filteredExpenses(from: expenses).reduce(0) { $0 + $1.amount }
    }

    func groupedExpenses(from expenses: [Expense]) -> [(dateString: String, items: [Expense])] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ka_GE")
        formatter.dateFormat = "d MMMM"

        let filtered = filteredExpenses(from: expenses)
        var groups: [String: [Expense]] = [:]
        var order: [String] = []

        for expense in filtered {
            let key = formatter.string(from: expense.date)
            if groups[key] == nil {
                groups[key] = []
                order.append(key)
            }
            groups[key]?.append(expense)
        }

        return order.compactMap { key in
            guard let items = groups[key] else { return nil }
            return (dateString: key, items: items)
        }
    }

    func addExpense(_ expense: Expense, context: ModelContext) {
        context.insert(expense)
    }

    func deleteExpense(_ expense: Expense, context: ModelContext) {
        context.delete(expense)
    }

    func deleteExpenses(at offsets: IndexSet, from items: [Expense], context: ModelContext) {
        for index in offsets {
            let item = items[index]
            context.delete(item)
        }
    }

    func seedInitialDataIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Expense>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        if count == 0 {
            for item in Expense.dummyExpenses {
                context.insert(item)
            }
        }
    }
}
