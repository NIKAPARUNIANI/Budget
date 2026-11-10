import Foundation
import SwiftData

@Model
class Expense {
    var id: UUID = UUID()
    var title: String = ""
    var amount: Double = 0.0
    var categoryRaw: String = ""
    var date: Date = Date()

    var category: Category {
        get { Category(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    init(id: UUID = UUID(), title: String, amount: Double, category: Category, date: Date = Date()) {
        self.id = id
        self.title = title
        self.amount = amount
        self.categoryRaw = category.rawValue
        self.date = date
    }

    static var dummyExpenses: [Expense] {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let month = 11

        let d1 = calendar.date(from: DateComponents(year: year, month: month, day: 3)) ?? now
        let d2 = calendar.date(from: DateComponents(year: year, month: month, day: 2)) ?? now
        let d3 = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? now

        return [
            Expense(title: "სადილი", amount: 25.00, category: .food, date: d1),
            Expense(title: "ავტობუსი", amount: 2.00, category: .transport, date: d2),
            Expense(title: "კინო", amount: 30.00, category: .entertainment, date: d3)
        ]
    }
}