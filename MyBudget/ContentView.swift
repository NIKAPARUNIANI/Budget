import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @StateObject private var viewModel = ExpenseViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                totalSummaryCard
                    .padding(.horizontal)
                    .padding(.top, 8)

                filterChipsBar

                if expenses.isEmpty {
                    emptyAllExpensesView
                } else if viewModel.filteredExpenses(from: expenses).isEmpty {
                    emptyFilteredCategoryView
                } else {
                    expenseList
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("ყველა ხარჯი")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !expenses.isEmpty {
                        EditButton()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.isShowingAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingAddExpense) {
                AddExpenseView { newExpense in
                    viewModel.addExpense(newExpense, context: modelContext)
                }
            }
            .onAppear {
                viewModel.seedInitialDataIfNeeded(context: modelContext)
            }
        }
    }

    private var totalSummaryCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.selectedCategory == nil ? "ამ თვის ხარჯი" : "ხარჯი: \(viewModel.selectedCategory!.rawValue)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("ჯამი: \(String(format: "%.2f", viewModel.totalAmount(for: expenses))) ₾")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    private var filterChipsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(title: "ყველა", isSelected: viewModel.selectedCategory == nil) {
                    viewModel.selectedCategory = nil
                }

                ForEach(Category.allCases) { category in
                    filterChip(title: category.rawValue, isSelected: viewModel.selectedCategory == category) {
                        viewModel.selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.secondarySystemGroupedBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }

    private var expenseList: some View {
        List {
            ForEach(viewModel.groupedExpenses(from: expenses), id: \.dateString) { group in
                Section(header: Text(group.dateString).font(.subheadline).fontWeight(.semibold)) {
                    ForEach(group.items) { expense in
                        HStack(spacing: 12) {
                            Image(systemName: expense.category.iconName)
                                .font(.title3)
                                .foregroundColor(.blue)
                                .frame(width: 32, height: 32)
                                .background(Color.blue.opacity(0.12))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(expense.title)
                                    .font(.body)
                                    .fontWeight(.medium)

                                Text(expense.category.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text("\(String(format: "%.2f", expense.amount)) ₾")
                                .font(.body)
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 2)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.deleteExpense(expense, context: modelContext)
                            } label: {
                                Label("წაშლა", systemImage: "trash")
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.deleteExpense(expense, context: modelContext)
                            } label: {
                                Label("წაშლა", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.deleteExpenses(at: indexSet, from: group.items, context: modelContext)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyAllExpensesView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("ხარჯების სია ცარიელია")
                .font(.headline)
                .foregroundColor(.primary)

            Text("ახალი ხარჯის დასამატებლად დააჭირეთ + ღილაკს")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
    }

    private var emptyFilteredCategoryView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("ამ კატეგორიაში ხარჯები არ არის")
                .font(.headline)
                .foregroundColor(.primary)

            Text("სცადეთ სხვა კატეგორიის არჩევა ან დაამატეთ ახალი ხარჯი")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
    }
}
