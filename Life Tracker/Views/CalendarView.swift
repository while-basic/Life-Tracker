// Created by Celaya Solutions 2025
//
//  CalendarView.swift
//  Life Tracker
//

import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = AppViewModel()
    @State private var selectedDate = Date()
    @State private var selectedTab = 0
    @State private var isEditingEvent: Event? = nil
    @State private var isAddingEvent = false
    @State private var editedEvent = Event(title: "", startTime: Date(), category: .general)
    @State private var isEditingExpense: Expense? = nil
    @State private var isAddingExpense = false
    @State private var editedExpense = Expense(name: "", amount: 0.0, dueDate: Date(), category: .other)
    @State private var calendarViewMode: CalendarViewMode = .day
    
    private var tabs = ["Events", "Work", "Gym", "Expenses"]
    
    enum CalendarViewMode: String, CaseIterable, Identifiable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        case year = "Year"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Calendar header with view mode selector
                VStack(spacing: 0) {
                    // View mode picker
                    Picker("Calendar View", selection: $calendarViewMode) {
                        ForEach(CalendarViewMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Different calendar views based on selected mode
                    switch calendarViewMode {
                    case .day:
                        dayCalendarView
                    case .week:
                        weekCalendarView
                    case .month:
                        monthCalendarView
                    case .year:
                        yearCalendarView
                    }
                }
                
                // Day summary header
                HStack {
                    VStack(alignment: .leading) {
                        Text(selectedDate.formatted(date: .complete, time: .omitted))
                            .font(.headline)
                        
                        let totalItems = eventsForSelectedDate.count + 
                                         shiftsForSelectedDate.count + 
                                         workoutsForSelectedDate.count + 
                                         expensesForSelectedDate.count +
                                         journalEntriesForSelectedDate.count
                        
                        Text(totalItems == 0 ? "No items scheduled" : "\(totalItems) items scheduled")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Unified day view
                ScrollView {
                    VStack(spacing: 20) {
                        // Events Section
                        if !eventsForSelectedDate.isEmpty {
                            daySection(title: "Events", systemImage: "calendar", items: eventsForSelectedDate.count) {
                                ForEach(eventsForSelectedDate) { event in
                                    editableEventCard(event)
                                }
                            }
                        }
                        
                        // Work Shifts Section
                        if !shiftsForSelectedDate.isEmpty {
                            daySection(title: "Work Shifts", systemImage: "briefcase.fill", items: shiftsForSelectedDate.count) {
                                ForEach(shiftsForSelectedDate) { shift in
                                    workShiftCard(shift)
                                }
                                
                                // Work Summary
                                CardView(title: "Work Summary", systemImage: "chart.bar.fill") {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Total Hours:")
                                                .font(.subheadline)
                                            
                                            Spacer()
                                            
                                            Text("\(totalHoursForSelectedDate, specifier: "%.1f")")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                        
                                        Divider()
                                        
                                        HStack {
                                            Text("Total Pay:")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            Spacer()
                                            
                                            Text("$\(totalPayForSelectedDate, specifier: "%.2f")")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Workouts Section
                        if !workoutsForSelectedDate.isEmpty {
                            daySection(title: "Workouts", systemImage: "figure.strengthtraining.traditional", items: workoutsForSelectedDate.count) {
                                ForEach(workoutsForSelectedDate) { workout in
                                    workoutCard(workout)
                                }
                            }
                        }
                        
                        // Expenses Section
                        if !expensesForSelectedDate.isEmpty {
                            daySection(title: "Expenses", systemImage: "dollarsign.circle", items: expensesForSelectedDate.count) {
                                ForEach(expensesForSelectedDate) { expense in
                                    editableExpenseCard(expense)
                                }
                                
                                // Expense Summary
                                CardView(title: "Expense Summary", systemImage: "chart.pie.fill") {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Total Expenses:")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            Spacer()
                                            
                                            Text("$\(totalExpensesForSelectedDate, specifier: "%.2f")")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Journal Entries Section
                        if !journalEntriesForSelectedDate.isEmpty {
                            daySection(title: "Journal Entries", systemImage: "book.fill", items: journalEntriesForSelectedDate.count) {
                                ForEach(journalEntriesForSelectedDate) { entry in
                                    journalEntryCard(entry)
                                }
                            }
                        }
                        
                        // Empty state
                        if eventsForSelectedDate.isEmpty && 
                           shiftsForSelectedDate.isEmpty && 
                           workoutsForSelectedDate.isEmpty && 
                           expensesForSelectedDate.isEmpty &&
                           journalEntriesForSelectedDate.isEmpty {
                            EmptyStateView(
                                title: "Nothing Scheduled",
                                message: "You don't have any items scheduled for this day. Tap the + button to add something.",
                                systemImage: "calendar.badge.plus"
                            )
                        }
                        
                        // Add extra space at the bottom for better scrolling
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            prepareForNewEvent()
                        }) {
                            Label("Add Event", systemImage: "calendar")
                        }
                        
                        Button(action: {
                            prepareForNewWorkShift()
                        }) {
                            Label("Add Work Shift", systemImage: "briefcase")
                        }
                        
                        Button(action: {
                            prepareForNewWorkout()
                        }) {
                            Label("Add Workout", systemImage: "figure.run")
                        }
                        
                        Button(action: {
                            prepareForNewExpense()
                        }) {
                            Label("Add Expense", systemImage: "dollarsign.circle")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $isEditingEvent) { event in
                eventEditorView(event: event)
            }
            .sheet(isPresented: $isAddingEvent) {
                eventEditorView(event: nil)
            }
            .sheet(item: $isEditingExpense) { expense in
                expenseEditorView(expense: expense)
            }
            .sheet(isPresented: $isAddingExpense) {
                expenseEditorView(expense: nil)
            }
            .sheet(item: $isEditingWorkShift) { shift in
                workShiftEditorView(shift: shift)
            }
            .sheet(isPresented: $isAddingWorkShift) {
                workShiftEditorView(shift: nil)
            }
            .sheet(item: $isEditingWorkout) { workout in
                workoutEditorView(workout: workout)
            }
            .sheet(isPresented: $isAddingWorkout) {
                workoutEditorView(workout: nil)
            }
            .sheet(item: $selectedJournalEntry) { entry in
                journalEntryDetailView(entry: entry)
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func daySection<Content: View>(title: String, systemImage: String, items: Int, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Text("\(items)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
            }
            
            content()
        }
    }
    
    // MARK: - Tab Views
    
    private var eventsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            if eventsForSelectedDate.isEmpty {
                EmptyStateView(
                    title: "No Events",
                    message: "You don't have any events scheduled for this day.",
                    systemImage: "calendar.badge.exclamationmark"
                )
            } else {
                Text("Events for \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.headline)
                    .padding(.horizontal, 4)
                
                ForEach(eventsForSelectedDate) { event in
                    editableEventCard(event)
                }
            }
        }
    }
    
    // MARK: - Editable Event Card
    
    private func editableEventCard(_ event: Event) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            EventCardView(event: event)
                .contentShape(Rectangle())
                .onTapGesture {
                    editEvent(event)
                }
            
            HStack {
                Spacer()
                
                Button(action: {
                    editEvent(event)
                }) {
                    Label("Edit", systemImage: "pencil")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.trailing, 8)
                
                Button(action: {
                    deleteEvent(event)
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
    
    // MARK: - Event Editor View
    
    private func eventEditorView(event: Event?) -> some View {
        let isNewEvent = event == nil
        
        // If editing existing event, make a copy. If creating new, use the prepared editedEvent
        if let event = event, !isNewEvent {
            editedEvent = event
        }
        
        return NavigationView {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Title", text: $editedEvent.title)
                    
                    Picker("Category", selection: $editedEvent.category) {
                        ForEach(Event.EventCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    TextField("Location", text: Binding(
                        get: { editedEvent.location ?? "" },
                        set: { editedEvent.location = $0.isEmpty ? nil : $0 }
                    ))
                    
                    Toggle("All Day Event", isOn: $editedEvent.isAllDay)
                    
                    DatePicker("Start Time", selection: $editedEvent.startTime, displayedComponents: editedEvent.isAllDay ? [.date] : [.date, .hourAndMinute])
                    
                    if !editedEvent.isAllDay {
                        DatePicker("End Time", selection: Binding(
                            get: { editedEvent.endTime ?? editedEvent.startTime.addingTimeInterval(3600) },
                            set: { editedEvent.endTime = $0 }
                        ), displayedComponents: [.date, .hourAndMinute])
                    }
                    
                    Toggle("Recurring Event", isOn: $editedEvent.isRecurring)
                    
                    if editedEvent.isRecurring {
                        Picker("Frequency", selection: Binding(
                            get: { editedEvent.recurringFrequency ?? .weekly },
                            set: { editedEvent.recurringFrequency = $0 }
                        )) {
                            ForEach(Event.RecurringFrequency.allCases, id: \.self) { frequency in
                                Text(frequency.rawValue).tag(frequency)
                            }
                        }
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: Binding(
                        get: { editedEvent.notes ?? "" },
                        set: { editedEvent.notes = $0.isEmpty ? nil : $0 }
                    ))
                    .frame(height: 100)
                }
                
                if editedEvent.category == .birthday || editedEvent.category == .anniversary {
                    Section(header: Text("Notifications")) {
                        Text("You'll be reminded \(editedEvent.category == .birthday ? "7" : "7") days before this \(editedEvent.category.rawValue.lowercased()).")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(isNewEvent ? "New Event" : "Edit Event")
            .navigationBarItems(
                leading: Button("Cancel") {
                    if isNewEvent {
                        isAddingEvent = false
                    } else {
                        isEditingEvent = nil
                    }
                },
                trailing: Button("Save") {
                    if isNewEvent {
                        viewModel.addEvent(editedEvent)
                        isAddingEvent = false
                    } else {
                        viewModel.updateEvent(editedEvent)
                        isEditingEvent = nil
                    }
                }
                .disabled(editedEvent.title.isEmpty)
            )
        }
    }
    
    // MARK: - Event Actions
    
    private func prepareForNewEvent() {
        // Initialize a new event with the selected date
        editedEvent = Event(
            title: "",
            description: nil,
            startTime: selectedDate,
            endTime: selectedDate.addingTimeInterval(3600),
            isAllDay: false,
            location: nil,
            category: .general,
            notes: nil,
            isRecurring: false,
            recurringFrequency: nil
        )
        isAddingEvent = true
    }
    
    private func editEvent(_ event: Event) {
        isEditingEvent = event
    }
    
    private func deleteEvent(_ event: Event) {
        viewModel.deleteEvent(event)
    }
    
    // MARK: - Card Builders
    
    private var workView: some View {
        VStack(alignment: .leading, spacing: 16) {
            if shiftsForSelectedDate.isEmpty {
                EmptyStateView(
                    title: "No Work Shifts",
                    message: "You don't have any work shifts scheduled for this day.",
                    systemImage: "briefcase"
                )
            } else {
                Text("Work for \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.headline)
                    .padding(.horizontal, 4)
                
                ForEach(shiftsForSelectedDate) { shift in
                    workShiftCard(shift)
                }
                
                // Summary card
                if !shiftsForSelectedDate.isEmpty {
                    CardView(title: "Work Summary", systemImage: "chart.bar.fill") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Total Hours:")
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text("\(totalHoursForSelectedDate, specifier: "%.1f")")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Regular Pay:")
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text("$\(totalRegularPayForSelectedDate, specifier: "%.2f")")
                                    .font(.subheadline)
                            }
                            
                            HStack {
                                Text("Overtime Pay:")
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text("$\(totalOvertimePayForSelectedDate, specifier: "%.2f")")
                                    .font(.subheadline)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Total Pay:")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Text("$\(totalPayForSelectedDate, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var gymView: some View {
        VStack(alignment: .leading, spacing: 16) {
            if workoutsForSelectedDate.isEmpty {
                EmptyStateView(
                    title: "No Workouts",
                    message: "You don't have any workouts scheduled for this day.",
                    systemImage: "figure.strengthtraining.traditional"
                )
            } else {
                Text("Workouts for \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.headline)
                    .padding(.horizontal, 4)
                
                ForEach(workoutsForSelectedDate) { workout in
                    workoutCard(workout)
                }
            }
        }
    }
    
    private var expensesView: some View {
        VStack(alignment: .leading, spacing: 16) {
            if expensesForSelectedDate.isEmpty {
                EmptyStateView(
                    title: "No Expenses",
                    message: "You don't have any expenses due on this day.",
                    systemImage: "dollarsign.circle"
                )
            } else {
                Text("Expenses for \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.headline)
                    .padding(.horizontal, 4)
                
                ForEach(expensesForSelectedDate) { expense in
                    editableExpenseCard(expense)
                }
                
                // Summary card
                if !expensesForSelectedDate.isEmpty {
                    CardView(title: "Expense Summary", systemImage: "chart.pie.fill") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Total Expenses:")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Text("$\(totalExpensesForSelectedDate, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func workShiftCard(_ shift: WorkShift) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            CardView(title: "Work Shift", systemImage: "briefcase.fill") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Time:")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(shift.startTime.formatted(date: .omitted, time: .shortened)) - \(shift.endTime.formatted(date: .omitted, time: .shortened))")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Text("Hours:")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(shift.hoursWorked, specifier: "%.1f") hrs")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Text("Pay Rate:")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("$\(shift.hourlyRate, specifier: "%.2f")/hr")
                            .font(.subheadline)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total Pay:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("$\(shift.totalPay, specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    if let notes = shift.notes {
                        Divider()
                        
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                editWorkShift(shift)
            }
            
            HStack {
                Spacer()
                
                Button(action: {
                    editWorkShift(shift)
                }) {
                    Label("Edit", systemImage: "pencil")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.trailing, 8)
                
                Button(action: {
                    deleteWorkShift(shift)
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
    
    private func workoutCard(_ workout: WorkoutSession) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            CardView(title: "Workout Session", systemImage: "figure.strengthtraining.traditional") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Duration:")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(Int(workout.duration / 60)) min")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Text("Exercises:")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(workout.exercises.count)")
                            .font(.subheadline)
                    }
                    
                    if !workout.exercises.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(workout.exercises.prefix(3)) { exercise in
                                Text("• \(exercise.name)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if workout.exercises.count > 3 {
                                Text("+ \(workout.exercises.count - 3) more")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    if let notes = workout.notes {
                        Divider()
                        
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                editWorkout(workout)
            }
            
            HStack {
                Spacer()
                
                Button(action: {
                    editWorkout(workout)
                }) {
                    Label("Edit", systemImage: "pencil")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.trailing, 8)
                
                Button(action: {
                    deleteWorkout(workout)
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
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
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
    
    // MARK: - Expense Actions
    
    private func prepareForNewExpense() {
        // Initialize a new expense with the selected date
        editedExpense = Expense(
            name: "",
            amount: 0.0,
            dueDate: selectedDate,
            isRecurring: false,
            recurringFrequency: nil,
            category: .other,
            notes: nil
        )
        isAddingExpense = true
    }
    
    private func editExpense(_ expense: Expense) {
        isEditingExpense = expense
    }
    
    private func deleteExpense(_ expense: Expense) {
        viewModel.deleteExpense(expense)
    }
    
    // MARK: - Filtered Data
    
    private var eventsForSelectedDate: [Event] {
        viewModel.events.filter { Calendar.current.isDate($0.startTime, inSameDayAs: selectedDate) }
    }
    
    private var shiftsForSelectedDate: [WorkShift] {
        viewModel.workShifts.filter { Calendar.current.isDate($0.startTime, inSameDayAs: selectedDate) }
    }
    
    private var workoutsForSelectedDate: [WorkoutSession] {
        viewModel.workoutSessions.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    private var expensesForSelectedDate: [Expense] {
        viewModel.expenses.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: selectedDate) }
    }
    
    private var journalEntriesForSelectedDate: [JournalEntry] {
        viewModel.journalEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    // MARK: - Computed Properties
    
    private var totalHoursForSelectedDate: Double {
        shiftsForSelectedDate.reduce(0) { $0 + $1.hoursWorked }
    }
    
    private var totalRegularPayForSelectedDate: Double {
        shiftsForSelectedDate.reduce(0) { $0 + $1.regularPay }
    }
    
    private var totalOvertimePayForSelectedDate: Double {
        shiftsForSelectedDate.reduce(0) { $0 + $1.overtimePay }
    }
    
    private var totalPayForSelectedDate: Double {
        shiftsForSelectedDate.reduce(0) { $0 + $1.totalPay }
    }
    
    private var totalExpensesForSelectedDate: Double {
        expensesForSelectedDate.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Actions
    
    private func addNewItem() {
        // This would open a sheet to add a new item based on selected tab
        switch selectedTab {
        case 0: // Events
            prepareForNewEvent()
            
        case 1: // Work
            let startTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: selectedDate) ?? selectedDate
            let endTime = startTime.addingTimeInterval(8 * 3600)
            let newShift = WorkShift(
                startTime: startTime,
                endTime: endTime,
                hourlyRate: 20.0
            )
            viewModel.addWorkShift(newShift)
            
        case 2: // Gym
            let newWorkout = WorkoutSession(
                date: selectedDate,
                duration: 60 * 60, // 1 hour
                exercises: []
            )
            viewModel.addWorkoutSession(newWorkout)
            
        case 3: // Expenses
            prepareForNewExpense()
            
        default:
            break
        }
    }
    
    // MARK: - Calendar Views
    
    private var dayCalendarView: some View {
        VStack {
            HStack {
                Button(action: {
                    // Move to previous day
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(selectedDate.formatted(date: .complete, time: .omitted))
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    // Move to next day
                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Day timeline view
            ScrollView {
                VStack(spacing: 0) {
                    // Display hours from 6 AM to 10 PM
                    ForEach(6..<23, id: \.self) { hour in
                        HStack(alignment: .top) {
                            // Hour label
                            Text(formatHour(hour))
                                .font(.caption)
                                .frame(width: 50, alignment: .center)
                            
                            // Events that occur at this hour
                            ZStack(alignment: .topLeading) {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 60)
                                    .overlay(
                                        Rectangle()
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                                    )
                                
                                // Get events for this hour
                                let hourEvents = eventsAtHour(hour: hour)
                                
                                ForEach(hourEvents) { event in
                                    Text(event.title)
                                        .font(.caption)
                                        .padding(4)
                                        .background(colorForEvent(event))
                                        .foregroundColor(.white)
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .frame(height: 300)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
    
    // Helper for day view
    private func formatHour(_ hour: Int) -> String {
        let hourValue = hour % 12 == 0 ? 12 : hour % 12
        let amPm = hour < 12 ? "AM" : "PM"
        return "\(hourValue) \(amPm)"
    }
    
    private func eventsAtHour(hour: Int) -> [Event] {
        let calendar = Calendar.current
        return eventsForSelectedDate.filter { event in
            let eventHour = calendar.component(.hour, from: event.startTime)
            return eventHour == hour
        }
    }
    
    private func colorForEvent(_ event: Event) -> Color {
        switch event.category {
        case .birthday, .anniversary:
            return .purple
        case .meeting:
            return .blue
        case .medication, .doctor:
            return .red
        case .gym:
            return .green
        case .studio:
            return .orange
        case .general:
            return .gray
        }
    }
    
    private var weekCalendarView: some View {
        VStack {
            HStack {
                Button(action: {
                    // Move to previous week
                    selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                let weekStartDate = startOfWeek(for: selectedDate)
                let weekEndDate = endOfWeek(for: selectedDate)
                
                Text("\(weekStartDate.formatted(date: .abbreviated, time: .omitted)) - \(weekEndDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    // Move to next week
                    selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Week view - 7 days
            VStack(spacing: 0) {
                // Day headers
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { index in
                        let day = Calendar.current.date(byAdding: .day, value: index, to: startOfWeek(for: selectedDate)) ?? Date()
                        
                        Text(day.formatted(.dateTime.weekday(.abbreviated)))
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
                .background(Color(.systemBackground).opacity(0.5))
                
                // Day cells
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { index in
                        let day = Calendar.current.date(byAdding: .day, value: index, to: startOfWeek(for: selectedDate)) ?? Date()
                        let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDate)
                        let hasEvents = !viewModel.events.filter { Calendar.current.isDate($0.startTime, inSameDayAs: day) }.isEmpty
                        
                        Button(action: {
                            selectedDate = day
                        }) {
                            VStack {
                                Text(day.formatted(.dateTime.day()))
                                    .font(.body)
                                    .fontWeight(isSelected ? .bold : .regular)
                                
                                if hasEvents {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 6, height: 6)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
    
    private var monthCalendarView: some View {
        VStack {
            HStack {
                Button(action: {
                    // Move to previous month
                    selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(selectedDate.formatted(.dateTime.month(.wide).year()))
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    // Move to next month
                    selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Month grid
            let daysInMonth = getMonthDays(for: selectedDate)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 2) {
                // Day headers
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Day cells
                ForEach(0..<daysInMonth.count, id: \.self) { index in
                    if let day = daysInMonth[index] {
                        let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDate)
                        let hasEvents = !viewModel.events.filter { Calendar.current.isDate($0.startTime, inSameDayAs: day) }.isEmpty
                        
                        Button(action: {
                            selectedDate = day
                        }) {
                            VStack {
                                Text(day.formatted(.dateTime.day()))
                                    .font(.body)
                                    .fontWeight(isSelected ? .bold : .regular)
                                
                                if hasEvents {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 4, height: 4)
                                }
                            }
                            .frame(height: 40)
                            .frame(maxWidth: .infinity)
                            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        // Empty cell
                        Text("")
                            .frame(height: 40)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
    
    private var yearCalendarView: some View {
        VStack {
            HStack {
                Button(action: {
                    // Move to previous year
                    selectedDate = Calendar.current.date(byAdding: .year, value: -1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(selectedDate.formatted(.dateTime.year()))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    // Move to next year
                    selectedDate = Calendar.current.date(byAdding: .year, value: 1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Year grid - months
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                ForEach(0..<12, id: \.self) { index in
                    let month = Calendar.current.date(
                        from: DateComponents(
                            year: Calendar.current.component(.year, from: selectedDate),
                            month: index + 1,
                            day: 1
                        )
                    ) ?? Date()
                    
                    let isSelected = Calendar.current.component(.month, from: selectedDate) == index + 1
                    
                    Button(action: {
                        // Update selected date to this month while preserving the day
                        let day = min(
                            Calendar.current.component(.day, from: selectedDate),
                            Calendar.current.range(of: .day, in: .month, for: month)?.count ?? 30
                        )
                        
                        selectedDate = Calendar.current.date(
                            from: DateComponents(
                                year: Calendar.current.component(.year, from: selectedDate),
                                month: index + 1,
                                day: day
                            )
                        ) ?? selectedDate
                        
                        // Switch to month view
                        calendarViewMode = .month
                    }) {
                        VStack {
                            Text(month.formatted(.dateTime.month(.abbreviated)))
                                .font(.headline)
                                .padding(.vertical, 8)
                        }
                        .frame(maxWidth: .infinity)
                        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Calendar Helper Methods
    
    private func startOfWeek(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }
    
    private func endOfWeek(for date: Date) -> Date {
        let calendar = Calendar.current
        let startOfWeek = startOfWeek(for: date)
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? date
        return endOfWeek
    }
    
    private func getMonthDays(for date: Date) -> [Date?] {
        let calendar = Calendar.current
        
        // Get start of the month
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let startOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return []
        }
        
        // Get weekday of the first day (0 = Sunday, 1 = Monday, etc.)
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        
        // Calculate offset for the first day (0-6)
        let offset = firstWeekday - 1
        
        // Create an array with all days of the month
        var days = [Date?](repeating: nil, count: 42) // 6 weeks * 7 days
        
        // Fill in the offset with nil
        for i in 0..<offset {
            days[i] = nil
        }
        
        // Fill in the days of the month
        for day in 1...range.count {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else { continue }
            days[offset + day - 1] = date
        }
        
        return days
    }
    
    // MARK: - Add additional work shift and workout editing functionality
    
    @State private var isEditingWorkShift: WorkShift? = nil
    @State private var isAddingWorkShift = false
    @State private var editedWorkShift = WorkShift(startTime: Date(), endTime: Date().addingTimeInterval(3600), hourlyRate: 20.0)
    
    @State private var isEditingWorkout: WorkoutSession? = nil
    @State private var isAddingWorkout = false
    @State private var editedWorkout = WorkoutSession(date: Date(), duration: 3600, exercises: [])
    
    // Work Shift Editor View
    private func workShiftEditorView(shift: WorkShift?) -> some View {
        let isNewShift = shift == nil
        
        // If editing existing shift, make a copy. If creating new, use the prepared editedWorkShift
        if let shift = shift, !isNewShift {
            editedWorkShift = shift
        }
        
        return NavigationView {
            Form {
                Section(header: Text("Work Shift Details")) {
                    DatePicker("Start Time", selection: $editedWorkShift.startTime)
                    
                    DatePicker("End Time", selection: $editedWorkShift.endTime)
                    
                    HStack {
                        Text("$")
                        TextField("Hourly Rate", value: $editedWorkShift.hourlyRate, format: .number)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: Binding(
                        get: { editedWorkShift.notes ?? "" },
                        set: { editedWorkShift.notes = $0.isEmpty ? nil : $0 }
                    ))
                    .frame(height: 100)
                }
                
                Section(header: Text("Summary")) {
                    HStack {
                        Text("Hours:")
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("\(editedWorkShift.hoursWorked, specifier: "%.1f")")
                    }
                    
                    HStack {
                        Text("Regular Pay:")
                        
                        Spacer()
                        
                        Text("$\(editedWorkShift.regularPay, specifier: "%.2f")")
                    }
                    
                    HStack {
                        Text("Overtime Pay:")
                        
                        Spacer()
                        
                        Text("$\(editedWorkShift.overtimePay, specifier: "%.2f")")
                    }
                    
                    HStack {
                        Text("Total Pay:")
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("$\(editedWorkShift.totalPay, specifier: "%.2f")")
                            .fontWeight(.semibold)
                    }
                }
            }
            .navigationTitle(isNewShift ? "New Work Shift" : "Edit Work Shift")
            .navigationBarItems(
                leading: Button("Cancel") {
                    if isNewShift {
                        isAddingWorkShift = false
                    } else {
                        isEditingWorkShift = nil
                    }
                },
                trailing: Button("Save") {
                    if isNewShift {
                        viewModel.addWorkShift(editedWorkShift)
                        isAddingWorkShift = false
                    } else {
                        viewModel.updateWorkShift(editedWorkShift)
                        isEditingWorkShift = nil
                    }
                }
                .disabled(editedWorkShift.hourlyRate <= 0 || editedWorkShift.endTime <= editedWorkShift.startTime)
            )
        }
    }
    
    // Workout Session Editor View
    private func workoutEditorView(workout: WorkoutSession?) -> some View {
        let isNewWorkout = workout == nil
        
        // If editing existing workout, make a copy. If creating new, use the prepared editedWorkout
        if let workout = workout, !isNewWorkout {
            editedWorkout = workout
        }
        
        return NavigationView {
            Form {
                Section(header: Text("Workout Details")) {
                    DatePicker("Date", selection: $editedWorkout.date, displayedComponents: [.date])
                    
                    Stepper("Duration: \(Int(editedWorkout.duration / 60)) minutes", 
                            value: Binding(
                                get: { Int(editedWorkout.duration / 60) },
                                set: { editedWorkout.duration = TimeInterval($0 * 60) }
                            ),
                            in: 5...240,
                            step: 5)
                }
                
                Section(header: Text("Exercises")) {
                    ForEach(editedWorkout.exercises.indices, id: \.self) { index in
                        VStack(alignment: .leading) {
                            TextField("Exercise Name", text: Binding(
                                get: { editedWorkout.exercises[index].name },
                                set: { 
                                    var exercise = editedWorkout.exercises[index]
                                    exercise.name = $0
                                    editedWorkout.exercises[index] = exercise
                                }
                            ))
                            
                            HStack {
                                Text("Sets: \(editedWorkout.exercises[index].sets.count)")
                                
                                Spacer()
                                
                                Button("Add Set") {
                                    var exercise = editedWorkout.exercises[index]
                                    exercise.sets.append(WorkoutSession.Exercise.ExerciseSet(reps: 10))
                                    editedWorkout.exercises[index] = exercise
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    .onDelete { indices in
                        editedWorkout.exercises.remove(atOffsets: indices)
                    }
                    
                    Button("Add Exercise") {
                        let newExercise = WorkoutSession.Exercise(id: UUID(), name: "", sets: [WorkoutSession.Exercise.ExerciseSet(reps: 10)])
                        editedWorkout.exercises.append(newExercise)
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: Binding(
                        get: { editedWorkout.notes ?? "" },
                        set: { editedWorkout.notes = $0.isEmpty ? nil : $0 }
                    ))
                    .frame(height: 100)
                }
            }
            .navigationTitle(isNewWorkout ? "New Workout" : "Edit Workout")
            .navigationBarItems(
                leading: Button("Cancel") {
                    if isNewWorkout {
                        isAddingWorkout = false
                    } else {
                        isEditingWorkout = nil
                    }
                },
                trailing: Button("Save") {
                    if isNewWorkout {
                        viewModel.addWorkoutSession(editedWorkout)
                        isAddingWorkout = false
                    } else {
                        viewModel.updateWorkoutSession(editedWorkout)
                        isEditingWorkout = nil
                    }
                }
            )
        }
    }
    
    private func prepareForNewWorkShift() {
        // Initialize a new work shift with the selected date
        // Set start time to 3:30pm of the selected date
        let calendar = Calendar.current
        var startTimeComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        startTimeComponents.hour = 15
        startTimeComponents.minute = 30
        let startTime = calendar.date(from: startTimeComponents) ?? selectedDate
        
        // Set end time to 12:00am of the next day
        var endTimeComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        endTimeComponents.day = endTimeComponents.day! + 1
        endTimeComponents.hour = 0
        endTimeComponents.minute = 0
        let endTime = calendar.date(from: endTimeComponents) ?? startTime.addingTimeInterval(8.5 * 3600)
        
        editedWorkShift = WorkShift(
            startTime: startTime,
            endTime: endTime,
            hourlyRate: 16.0
        )
        
        isAddingWorkShift = true
    }
    
    private func editWorkShift(_ shift: WorkShift) {
        isEditingWorkShift = shift
    }
    
    private func deleteWorkShift(_ shift: WorkShift) {
        viewModel.deleteWorkShift(shift)
    }
    
    private func prepareForNewWorkout() {
        // Initialize a new workout with the selected date
        editedWorkout = WorkoutSession(
            date: selectedDate,
            duration: 60 * 60, // 1 hour
            exercises: []
        )
        
        isAddingWorkout = true
    }
    
    private func editWorkout(_ workout: WorkoutSession) {
        isEditingWorkout = workout
    }
    
    private func deleteWorkout(_ workout: WorkoutSession) {
        viewModel.deleteWorkoutSession(workout)
    }
    
    // MARK: - Journal Entry Card
    
    private func journalEntryCard(_ entry: JournalEntry) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            CardView(title: "Journal Entry", systemImage: "text.book.closed") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(entry.date.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if let mood = entry.mood {
                            Text(mood.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(moodColor(for: mood).opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(entry.content)
                        .font(.subheadline)
                        .lineLimit(3)
                    
                    if let tags = entry.tags, !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(4)
                                }
                            }
                        }
                        .frame(height: 24)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewJournalEntry(entry)
            }
            
            HStack {
                Spacer()
                
                Button(action: {
                    viewJournalEntry(entry)
                }) {
                    Label("View", systemImage: "eye")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.trailing, 8)
            }
            .padding(.vertical, 4)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func moodColor(for mood: JournalEntry.Mood) -> Color {
        switch mood {
        case .excellent:
            return .green
        case .good:
            return .mint
        case .neutral:
            return .yellow
        case .bad:
            return .orange
        case .terrible:
            return .red
        }
    }
    
    @State private var selectedJournalEntry: JournalEntry? = nil
    @State private var isViewingJournalEntry = false
    
    private func viewJournalEntry(_ entry: JournalEntry) {
        selectedJournalEntry = entry
        isViewingJournalEntry = true
    }
    
    private func journalEntryDetailView(entry: JournalEntry) -> some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(entry.date.formatted(date: .long, time: .shortened))
                            .font(.headline)
                        
                        Spacer()
                        
                        if let mood = entry.mood {
                            HStack(spacing: 4) {
                                Text("Mood:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(mood.rawValue)
                                    .font(.subheadline)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(moodColor(for: mood).opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Tags
                    if let tags = entry.tags, !tags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.subheadline)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        Divider()
                    }
                    
                    // Content
                    Text(entry.content)
                        .font(.body)
                        .lineSpacing(4)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Journal Entry")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedJournalEntry = nil
                    }) {
                        Text("Close")
                    }
                }
            }
        }
    }
}

#Preview {
    CalendarView()
} 