import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss

    var onSave: (Expense) -> Void

    @State private var title: String = ""
    @State private var amountText: String = ""
    @State private var category: Category = .food
    @State private var date: Date = Date()

    @State private var showAlert: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("დასახელება") {
                    TextField("მაგ. სადილი", text: $title)
                }

                Section("თანხა") {
                    HStack {
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                        Text("₾")
                            .foregroundColor(.secondary)
                    }
                }

                Section("კატეგორია") {
                    Picker("კატეგორია", selection: $category) {
                        ForEach(Category.allCases) { item in
                            HStack {
                                Image(systemName: item.iconName)
                                Text(item.rawValue)
                            }
                            .tag(item)
                        }
                    }
                }

                Section("თარიღი") {
                    DatePicker("თარიღი", selection: $date, displayedComponents: .date)
                }

                Section {
                    Button(action: saveExpense) {
                        HStack {
                            Spacer()
                            Text("შენახვა")
                                .bold()
                            Spacer()
                        }
                    }

                    Button("გაუქმება", role: .cancel) {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("ახალი ხარჯი")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("დახურვა") {
                        dismiss()
                    }
                }
            }
            .alert("შეცდომა", isPresented: $showAlert) {
                Button("კარგი", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func saveExpense() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            errorMessage = "გთხოვთ შეიყვანოთ დასახელება."
            showAlert = true
            return
        }

        let parsedAmountString = amountText.replacingOccurrences(of: ",", with: ".")
        guard let amount = Double(parsedAmountString), amount > 0 else {
            errorMessage = "გთხოვთ შეიყვანოთ დადებითი თანხა."
            showAlert = true
            return
        }

        let expense = Expense(
            title: trimmedTitle,
            amount: amount,
            category: category,
            date: date
        )
        onSave(expense)
        dismiss()
    }
}