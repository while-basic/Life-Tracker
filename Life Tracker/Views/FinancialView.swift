// Created by Celaya Solutions 2025
//
//  FinancialView.swift
//  Life Tracker
//
//

import SwiftUI
import Charts
import Foundation

struct FinancialView: View {
    @StateObject private var viewModel = AppViewModel()
    @State private var selectedTab = 0
    
    private var tabs = ["Overview", "Expenses", "Income", "Goals"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                HStack(spacing: 0) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Button(action: {
                            selectedTab = index
                        }) {
                            Text(tabs[index])
                                .font(.subheadline)
                                .fontWeight(selectedTab == index ? .semibold : .regular)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(
                                    selectedTab == index ?
                                    Color.blue.opacity(0.1) :
                                    Color.clear
                                )
                                .foregroundColor(selectedTab == index ? .blue : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                .padding(.top)
                
                // Content based on selected tab
                ScrollView {
                    VStack(spacing: 16) {
                        switch selectedTab {
                        case 0: // Overview
                            overviewView
                        case 1: // Expenses
                            expensesView
                        case 2: // Income
                            incomeView
                        case 3: // Goals
                            goalsView
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Financial")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Action to add new item based on selected tab
                        addNewItem()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(item: $isEditingExpense) { expense in
            expenseEditorView(expense: expense)
        }
        .sheet(isPresented: $isAddingExpense) {
            expenseEditorView(expense: nil)
        }
        .sheet(item: $isEditingIncome) { income in
            incomeEditorView(income: income)
        }
        .sheet(isPresented: $isAddingIncome) {
            incomeEditorView(income: nil)
        }
        .sheet(item: $isEditingGoal) { goal in
            goalEditorView(goal: goal)
        }
        .sheet(isPresented: $isAddingGoal) {
            goalEditorView(goal: nil)
        }
    }
    
    // MARK: - Tab Views
    
    private var overviewView: some View {
        VStack(spacing: 20) {
            // Financial Summary Card
            CardView(title: "Financial Summary", systemImage: "chart.pie.fill") {
                VStack(spacing: 16) {
                    // Income vs Expenses
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Income")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("$\(String(format: "%.2f", viewModel.totalIncome))")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Expenses")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("$\(String(format: "%.2f", viewModel.totalExpenses))")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                        }
                    }
                    
                    Divider()
                    
                    // Net Worth
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Net Worth")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("$\(String(format: "%.2f", viewModel.netWorth))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(viewModel.netWorth >= 0 ? .green : .red)
                    }
                }
            }
            
            // Predictive Analytics
            CardView(title: "Predictive Analytics", systemImage: "chart.line.uptrend.xyaxis") {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Cash Flow Forecast (6 Months)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    // Simple chart visualization
                    cashFlowChart
                    
                    Text("Based on your current income and expenses, you're projected to have a positive cash flow over the next 6 months.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Smart Alerts
            CardView(title: "Smart Alerts", systemImage: "bell.fill") {
                VStack(alignment: .leading, spacing: 12) {
                    alertView(
                        title: "Overtime Opportunity",
                        message: "You've consistently hit overtime—consider asking for a shift differential boost.",
                        iconName: "dollarsign.circle.fill",
                        color: .green
                    )
                    
                    Divider()
                    
                    alertView(
                        title: "Budget Warning",
                        message: "Your phone bill just spiked—here's how it'll impact your June budget.",
                        iconName: "exclamationmark.triangle.fill",
                        color: .orange
                    )
                }
            }
        }
    }
    
    private var expensesView: some View {
        VStack(spacing: 20) {
            // Expenses by Category
            CardView(title: "Expenses by Category", systemImage: "chart.pie.fill") {
                VStack(alignment: .leading, spacing: 16) {
                    // Dynamic chart based on actual expense data
                    dynamicExpenseCategoryChart
                }
            }
            
            // Upcoming Expenses
            CardView(title: "Upcoming Expenses", systemImage: "calendar") { () -> AnyView in
                if viewModel.upcomingExpenses.isEmpty {
                    return AnyView(
                        VStack {
                            Text("No upcoming expenses")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        }
                    )
                } else {
                    return AnyView(
                        VStack(spacing: 16) {
                            ForEach(viewModel.upcomingExpenses) { expense in
                                editableExpenseCard(expense)
                            }
                        }
                    )
                }
            }
            
            // All Expenses
            CardView(title: "All Expenses", systemImage: "list.bullet") { () -> AnyView in
                if viewModel.expenses.isEmpty {
                    return AnyView(
                        VStack {
                            Text("No expenses")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        }
                    )
                } else {
                    return AnyView(
                        VStack(spacing: 16) {
                            ForEach(viewModel.expenses) { expense in
                                editableExpenseCard(expense)
                            }
                        }
                    )
                }
            }
        }
    }
    
    private var incomeView: some View {
        VStack(spacing: 20) {
            // Income Summary
            CardView(title: "Income Summary", systemImage: "dollarsign.circle") {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Total Income")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("$\(String(format: "%.2f", viewModel.totalIncome))")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Sources")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(viewModel.incomes.count)")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            
            // Upcoming Income
            CardView(title: "Upcoming Income", systemImage: "calendar") { () -> AnyView in
                if viewModel.incomes.isEmpty {
                    return AnyView(
                        VStack {
                            Text("No upcoming income")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        }
                    )
                } else {
                    return AnyView(
                        VStack(spacing: 16) {
                            ForEach(viewModel.incomes) { income in
                                editableIncomeCard(income)
                            }
                        }
                    )
                }
            }
        }
    }
    
    private var goalsView: some View {
        VStack(spacing: 20) {
            // Savings Goals
            if viewModel.savingsGoals.isEmpty {
                EmptyStateView(
                    title: "No Savings Goals",
                    message: "You haven't set any savings goals yet. Tap the + button to add one.",
                    systemImage: "chart.bar.fill"
                )
            } else {
                ForEach(viewModel.savingsGoals) { goal in
                    editableGoalCard(goal)
                }
            }
        }
    }
    
    // MARK: - Card Builders
    
    private func alertView(title: String, message: String, iconName: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .foregroundColor(color)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func incomeCard(_ income: Income) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(incomeColor(for: income.source))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: incomeIcon(for: income.source))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(income.name)
                    .font(.headline)
                
                Text(income.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if income.isRecurring, let frequency = income.recurringFrequency {
                    Text("Recurring \(frequency.rawValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text("$\(String(format: "%.2f", income.amount))")
                .font(.headline)
                .foregroundColor(.green)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func savingsGoalCard(_ goal: SavingsGoal) -> some View {
        CardView(title: goal.name, systemImage: "star.fill") { () -> AnyView in
            return AnyView(
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Progress")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("$\(String(format: "%.0f", goal.currentAmount)) / $\(String(format: "%.0f", goal.targetAmount))")
                            .font(.subheadline)
                    }
                    
                    ProgressBarView(value: goal.progress, color: .green)
                        .frame(height: 8)
                    
                    HStack {
                        Text("\(Int(goal.progress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if let targetDate = goal.targetDate {
                            Text("Target: \(targetDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let notes = goal.notes {
                        Divider()
                        
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            )
        }
    }
    
    // MARK: - Editable Expense Card
    
    private func editableExpenseCard(_ expense: Expense) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ExpenseCardView(expense: expense)
                .contentShape(Rectangle())
                .onTapGesture {
                    editExpense(expense)
                }
            
            HStack {
                Spacer()
                
                Button(action: {
                    editExpense(expense)
                }) {
                    Label("Edit", systemImage: "pencil")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.trailing, 8)
                
                Button(action: {
                    deleteExpense(expense)
                }) {
                    Label("Delete", systemImage: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.trailing, 16)
            }
            .padding(.vertical, 4)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Editable Income Card
    
    private func editableIncomeCard(_ income: Income) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            incomeCard(income)
                .contentShape(Rectangle())
                .onTapGesture {
                    editIncome(income)
                }
            
            HStack {
                Spacer()
                
                Button(action: {
                    editIncome(income)
                }) {
                    Label("Edit", systemImage: "pencil")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.trailing, 8)
                
                Button(action: {
                    deleteIncome(income)
                }) {
                    Label("Delete", systemImage: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.trailing, 16)
            }
            .padding(.vertical, 4)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Editable Goal Card
    
    private func editableGoalCard(_ goal: SavingsGoal) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            savingsGoalCard(goal)
                .contentShape(Rectangle())
                .onTapGesture {
                    editGoal(goal)
                }
            
            HStack {
                Spacer()
                
                Button(action: {
                    editGoal(goal)
                }) {
                    Label("Edit", systemImage: "pencil")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.trailing, 8)
                
                Button(action: {
                    deleteGoal(goal)
                }) {
                    Label("Delete", systemImage: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.trailing, 16)
            }
            .padding(.vertical, 4)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Charts
    
    private var cashFlowChart: some View {
        // Create chart based on actual income and expense data
        let monthsToShow = 6
        let calendar = Calendar.current
        let currentDate = Date()
        
        // Get data for the last 6 months
        let monthData = (0..<monthsToShow).map { index -> (String, Double) in
            let monthDate = calendar.date(byAdding: .month, value: -index, to: currentDate)!
            let monthName = monthDate.formatted(.dateTime.month(.abbreviated))
            
            // Calculate net cash flow for this month
            let monthStart = calendar.dateInterval(of: .month, for: monthDate)!.start
            let monthEnd = calendar.dateInterval(of: .month, for: monthDate)!.end
            
            let monthlyIncome = viewModel.incomes
                .filter { $0.date >= monthStart && $0.date < monthEnd }
                .reduce(0) { $0 + $1.amount }
            
            let monthlyExpenses = viewModel.expenses
                .filter { $0.dueDate >= monthStart && $0.dueDate < monthEnd }
                .reduce(0) { $0 + $1.amount }
            
            let netCashFlow = monthlyIncome - monthlyExpenses
            
            return (monthName, netCashFlow)
        }.reversed()
        
        if monthData.isEmpty {
            return AnyView(
                Text("No financial data available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity, alignment: .center)
            )
        }
        
        return AnyView(
            Chart {
                // Add line marks
                ForEach(Array(monthData.enumerated()), id: \.element.0) { index, data in
                    LineMark(
                        x: .value("Month", data.0),
                        y: .value("Balance", data.1)
                    )
                    .foregroundStyle(.blue)
                }
                
                // Add point marks
                ForEach(Array(monthData.enumerated()), id: \.element.0) { index, data in
                    PointMark(
                        x: .value("Month", data.0),
                        y: .value("Balance", data.1)
                    )
                    .foregroundStyle(.blue)
                }
            }
            .frame(height: 150)
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        )
    }
    
    private var dynamicExpenseCategoryChart: some View {
        // Group expenses by category and sum amounts
        let categoryTotals = Dictionary(grouping: viewModel.expenses, by: { $0.category })
            .mapValues { expenses in
                expenses.reduce(0) { $0 + $1.amount }
            }
        
        if categoryTotals.isEmpty {
            return AnyView(
                Text("No expense data available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity, alignment: .center)
            )
        }
        
        return AnyView(
            Chart {
                ForEach(Array(categoryTotals.keys), id: \.self) { category in
                    BarMark(
                        x: .value("Category", category.rawValue),
                        y: .value("Amount", categoryTotals[category] ?? 0)
                    )
                    .foregroundStyle(categoryColor(for: category))
                }
            }
            .frame(height: 150)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        )
    }
    
    private func categoryColor(for category: Expense.ExpenseCategory) -> Color {
        switch category {
        case .housing:
            return .blue
        case .utilities:
            return .yellow
        case .food:
            return .green
        case .transportation:
            return .orange
        case .entertainment:
            return .purple
        case .healthcare:
            return .red
        case .education:
            return .cyan
        case .personal:
            return .mint
        case .debt:
            return .gray
        case .other:
            return .brown
        }
    }
    
    // MARK: - Helper Functions
    
    private func incomeColor(for source: Income.IncomeSource) -> Color {
        switch source {
        case .salary:
            return .blue
        case .freelance:
            return .purple
        case .investment:
            return .green
        case .gift:
            return .pink
        case .other:
            return .gray
        }
    }
    
    private func incomeIcon(for source: Income.IncomeSource) -> String {
        switch source {
        case .salary:
            return "briefcase.fill"
        case .freelance:
            return "laptopcomputer"
        case .investment:
            return "chart.line.uptrend.xyaxis"
        case .gift:
            return "gift.fill"
        case .other:
            return "square.fill"
        }
    }
    
    // MARK: - Actions
    
    @State private var isEditingExpense: Expense? = nil
    @State private var isAddingExpense = false
    @State private var editedExpense = Expense(name: "", amount: 0.0, dueDate: Date(), category: .other)
    
    @State private var isEditingIncome: Income? = nil
    @State private var isAddingIncome = false
    @State private var editedIncome = Income(name: "", amount: 0.0, date: Date(), source: .other)
    
    @State private var isEditingGoal: SavingsGoal? = nil
    @State private var isAddingGoal = false
    @State private var editedGoal = SavingsGoal(name: "", targetAmount: 0.0, currentAmount: 0.0)
    
    private func editExpense(_ expense: Expense) {
        isEditingExpense = expense
    }
    
    private func deleteExpense(_ expense: Expense) {
        viewModel.deleteExpense(expense)
    }
    
    private func prepareForNewExpense() {
        editedExpense = Expense(
            name: "",
            amount: 0.0,
            dueDate: Date(),
            isRecurring: false,
            recurringFrequency: nil,
            category: .other,
            notes: nil
        )
        isAddingExpense = true
    }
    
    private func editIncome(_ income: Income) {
        isEditingIncome = income
    }
    
    private func deleteIncome(_ income: Income) {
        viewModel.deleteIncome(income)
    }
    
    private func prepareForNewIncome() {
        editedIncome = Income(
            name: "",
            amount: 0.0,
            date: Date(),
            isRecurring: false,
            recurringFrequency: nil,
            source: .other,
            notes: nil
        )
        isAddingIncome = true
    }
    
    private func editGoal(_ goal: SavingsGoal) {
        isEditingGoal = goal
    }
    
    private func deleteGoal(_ goal: SavingsGoal) {
        viewModel.deleteSavingsGoal(goal)
    }
    
    private func prepareForNewGoal() {
        editedGoal = SavingsGoal(
            name: "",
            targetAmount: 0.0,
            currentAmount: 0.0,
            targetDate: Date().addingTimeInterval(86400 * 90), // 3 months from now
            notes: nil
        )
        isAddingGoal = true
    }
    
    private func addNewItem() {
        // Open appropriate editor based on selected tab
        switch selectedTab {
        case 1: // Expenses
            prepareForNewExpense()
            
        case 2: // Income
            prepareForNewIncome()
            
        case 3: // Goals
            prepareForNewGoal()
            
        default:
            break
        }
    }
    
    // MARK: - Expense Editor View
    
    private func expenseEditorView(expense: Expense?) -> some View {
        let isNewExpense = expense == nil
        
        // If editing existing expense, make a copy. If creating new, use the prepared editedExpense
        if let expense = expense, !isNewExpense {
            editedExpense = expense
        }
        
        return NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    TextField("Name", text: $editedExpense.name)
                    
                    HStack {
                        Text("$")
                        TextField("Amount", value: $editedExpense.amount, format: .number)
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker("Category", selection: $editedExpense.category) {
                        ForEach(Expense.ExpenseCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    DatePicker("Due Date", selection: $editedExpense.dueDate, displayedComponents: [.date])
                    
                    Toggle("Recurring Expense", isOn: $editedExpense.isRecurring)
                    
                    if editedExpense.isRecurring {
                        Picker("Frequency", selection: Binding(
                            get: { editedExpense.recurringFrequency ?? .monthly },
                            set: { editedExpense.recurringFrequency = $0 }
                        )) {
                            ForEach(Event.RecurringFrequency.allCases, id: \.self) { frequency in
                                Text(frequency.rawValue).tag(frequency)
                            }
                        }
                    }
                    
                    Toggle("Paid", isOn: $editedExpense.isPaid)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: Binding(
                        get: { editedExpense.notes ?? "" },
                        set: { editedExpense.notes = $0.isEmpty ? nil : $0 }
                    ))
                    .frame(height: 100)
                }
            }
            .navigationTitle(isNewExpense ? "New Expense" : "Edit Expense")
            .navigationBarItems(
                leading: Button("Cancel") {
                    if isNewExpense {
                        isAddingExpense = false
                    } else {
                        isEditingExpense = nil
                    }
                },
                trailing: Button("Save") {
                    if isNewExpense {
                        viewModel.addExpense(editedExpense)
                        isAddingExpense = false
                    } else {
                        viewModel.updateExpense(editedExpense)
                        isEditingExpense = nil
                    }
                }
                .disabled(editedExpense.name.isEmpty || editedExpense.amount <= 0)
            )
        }
    }
    
    // MARK: - Income Editor View
    
    private func incomeEditorView(income: Income?) -> some View {
        let isNewIncome = income == nil
        
        // If editing existing income, make a copy. If creating new, use the prepared editedIncome
        if let income = income, !isNewIncome {
            editedIncome = income
        }
        
        return NavigationView {
            Form {
                Section(header: Text("Income Details")) {
                    TextField("Name", text: $editedIncome.name)
                    
                    HStack {
                        Text("$")
                        TextField("Amount", value: $editedIncome.amount, format: .number)
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker("Source", selection: $editedIncome.source) {
                        ForEach(Income.IncomeSource.allCases, id: \.self) { source in
                            Text(source.rawValue).tag(source)
                        }
                    }
                    
                    DatePicker("Date", selection: $editedIncome.date, displayedComponents: [.date])
                    
                    Toggle("Recurring Income", isOn: $editedIncome.isRecurring)
                    
                    if editedIncome.isRecurring {
                        Picker("Frequency", selection: Binding(
                            get: { editedIncome.recurringFrequency ?? .monthly },
                            set: { editedIncome.recurringFrequency = $0 }
                        )) {
                            ForEach(Event.RecurringFrequency.allCases, id: \.self) { frequency in
                                Text(frequency.rawValue).tag(frequency)
                            }
                        }
                    }
                    
                    Toggle("Paid", isOn: $editedIncome.isPaid)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: Binding(
                        get: { editedIncome.notes ?? "" },
                        set: { editedIncome.notes = $0.isEmpty ? nil : $0 }
                    ))
                    .frame(height: 100)
                }
            }
            .navigationTitle(isNewIncome ? "New Income" : "Edit Income")
            .navigationBarItems(
                leading: Button("Cancel") {
                    if isNewIncome {
                        isAddingIncome = false
                    } else {
                        isEditingIncome = nil
                    }
                },
                trailing: Button("Save") {
                    if isNewIncome {
                        viewModel.addIncome(editedIncome)
                        isAddingIncome = false
                    } else {
                        viewModel.updateIncome(editedIncome)
                        isEditingIncome = nil
                    }
                }
                .disabled(editedIncome.name.isEmpty || editedIncome.amount <= 0)
            )
        }
    }
    
    // MARK: - Goal Editor View
    
    private func goalEditorView(goal: SavingsGoal?) -> some View {
        let isNewGoal = goal == nil
        
        // If editing existing goal, make a copy. If creating new, use the prepared editedGoal
        if let goal = goal, !isNewGoal {
            editedGoal = goal
        }
        
        return NavigationView {
            Form {
                Section(header: Text("Savings Goal Details")) {
                    TextField("Name", text: $editedGoal.name)
                    
                    HStack {
                        Text("$")
                        TextField("Target Amount", value: $editedGoal.targetAmount, format: .number)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("$")
                        TextField("Current Amount", value: $editedGoal.currentAmount, format: .number)
                            .keyboardType(.decimalPad)
                    }
                    
                    DatePicker(
                        "Target Date",
                        selection: Binding<Date>(
                            get: { editedGoal.targetDate ?? Date() },
                            set: { editedGoal.targetDate = $0 }
                        ),
                        displayedComponents: [.date]
                    )
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: Binding(
                        get: { editedGoal.notes ?? "" },
                        set: { editedGoal.notes = $0.isEmpty ? nil : $0 }
                    ))
                    .frame(height: 100)
                }
            }
            .navigationTitle(isNewGoal ? "New Savings Goal" : "Edit Savings Goal")
            .navigationBarItems(
                leading: Button("Cancel") {
                    if isNewGoal {
                        isAddingGoal = false
                    } else {
                        isEditingGoal = nil
                    }
                },
                trailing: Button("Save") {
                    if isNewGoal {
                        viewModel.addSavingsGoal(editedGoal)
                        isAddingGoal = false
                    } else {
                        viewModel.updateSavingsGoal(editedGoal)
                        isEditingGoal = nil
                    }
                }
                .disabled(editedGoal.name.isEmpty || editedGoal.targetAmount <= 0)
            )
        }
    }
}

#Preview {
    FinancialView()
} 