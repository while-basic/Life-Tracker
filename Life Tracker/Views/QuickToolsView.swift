// Created by Celaya Solutions 2025
//
//  QuickToolsView.swift
//  Life Tracker
//

import SwiftUI

struct QuickToolsView: View {
    @StateObject private var viewModel = AppViewModel()
    @State private var selectedTool = 0
    @State private var selectedEvent: Event?
    @State private var showingEventPicker = false
    @State private var journalContent = ""
    @State private var selectedStoryPeriod: Story.StoryPeriod = .weekly
    @State private var showingAddBucketItem = false
    @State private var newBucketItem = BucketListItem(title: "", description: "")
    @State private var selectedMood: JournalEntry.Mood?
    @State private var journalTags: [String] = []
    @State private var newTag: String = ""
    @State private var showingStoryDetail = false
    @State private var showingEntriesList = false
    @State private var selectedStory: Story?
    @State private var storyFilterPeriod: Story.StoryPeriod?
    @State private var showingGoalEditor: Bool = false
    @State private var editingGoal: SavingsGoal?
    
    private var tools = ["Countdown", "Storybook", "Paycheck", "Goals", "Bucket List", "Time Remaining"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tool selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(0..<tools.count, id: \.self) { index in
                            Button(action: {
                                selectedTool = index
                            }) {
                                VStack {
                                    Image(systemName: toolIcon(for: index))
                                        .font(.system(size: 24))
                                        .foregroundColor(selectedTool == index ? .blue : .gray)
                                    
                                    Text(tools[index])
                                        .font(.caption)
                                        .foregroundColor(selectedTool == index ? .blue : .gray)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 8)
                                .background(
                                    selectedTool == index ?
                                    Color.blue.opacity(0.1) :
                                    Color.clear
                                )
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                // Tool content
                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedTool {
                        case 0: // Countdown
                            countdownView
                        case 1: // Storybook
                            storybookView
                        case 2: // Paycheck Calculator
                            paycheckCalculatorView
                        case 3: // Goals Editor
                            goalsEditorView
                        case 4: // Bucket List
                            bucketListView
                        case 5: // Time Remaining
                            TimeRemainingView()
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Quick Tools")
            .sheet(isPresented: $showingEventPicker) {
                eventPickerView
            }
            .sheet(isPresented: $showingAddBucketItem) {
                addBucketItemView
            }
        }
    }
    
    // MARK: - Tool Views
    
    private var countdownView: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Countdown to Event")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    showingEventPicker = true
                }) {
                    Label("Select Event", systemImage: "calendar")
                        .font(.subheadline)
                }
            }
            
            if let event = selectedEvent {
                CountdownTimerView(
                    targetDate: event.startTime,
                    title: "Countdown to: \(event.title)"
                )
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No event selected")
                        .font(.headline)
                    
                    Text("Select an event to start the countdown")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        showingEventPicker = true
                    }) {
                        Text("Select Event")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var eventPickerView: some View {
        NavigationView {
            List {
                ForEach(viewModel.events) { event in
                    Button(action: {
                        selectedEvent = event
                        showingEventPicker = false
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title)
                                .font(.headline)
                            
                            Text(event.startTime.formatted(date: .abbreviated, time: .shortened))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Select Event")
            .navigationBarItems(trailing: Button("Cancel") {
                showingEventPicker = false
            })
        }
    }
    
    private var storybookView: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Storybook")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    viewModel.generateStory(for: selectedStoryPeriod)
                }) {
                    Label("Generate Story", systemImage: "wand.and.stars")
                        .font(.subheadline)
                }
            }
            
            // Analytics section
            VStack(spacing: 16) {
                HStack(spacing: 20) {
                    analyticCard(
                        title: "Entries",
                        value: "\(viewModel.journalEntries.count)",
                        icon: "book.closed",
                        color: .blue
                    )
                    
                    analyticCard(
                        title: "Words Written",
                        value: "\(totalWordsWritten)",
                        icon: "text.word.count",
                        color: .green
                    )
                    
                    analyticCard(
                        title: "Days Journaled",
                        value: "\(uniqueDaysJournaled)",
                        icon: "calendar",
                        color: .orange
                    )
                }
                .padding(.vertical, 8)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Journal Entry
            VStack(alignment: .leading, spacing: 12) {
                Text("Today's Journal Entry")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                TextEditor(text: $journalContent)
                    .frame(height: 120)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                HStack {
                    Text("\(journalContent.split(separator: " ").count) words")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        let entry = JournalEntry(
                            date: Date(),
                            content: journalContent,
                            mood: selectedMood,
                            tags: journalTags.isEmpty ? nil : journalTags
                        )
                        viewModel.addJournalEntry(entry)
                        journalContent = ""
                        journalTags = []
                    }) {
                        Text("Save Entry")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(journalContent.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(8)
                    }
                    .disabled(journalContent.isEmpty)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("How are you feeling?")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Mood", selection: $selectedMood) {
                        Text("Select mood").tag(nil as JournalEntry.Mood?)
                        ForEach(JournalEntry.Mood.allCases, id: \.self) { mood in
                            Text(mood.rawValue).tag(mood as JournalEntry.Mood?)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                if !journalTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(journalTags, id: \.self) { tag in
                                HStack {
                                    Text(tag)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                    
                                    Button(action: {
                                        journalTags.removeAll { $0 == tag }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                
                HStack {
                    TextField("Add tag", text: $newTag)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        if !newTag.isEmpty && !journalTags.contains(newTag) {
                            journalTags.append(newTag)
                            newTag = ""
                        }
                    }) {
                        Text("Add")
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(newTag.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(8)
                    }
                    .disabled(newTag.isEmpty)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Story Period Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Generate Story For:")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Picker("Story Period", selection: $selectedStoryPeriod) {
                    ForEach(Story.StoryPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Stories List
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Your Stories")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Picker("Filter", selection: $storyFilterPeriod) {
                        Text("All").tag(nil as Story.StoryPeriod?)
                        ForEach(Story.StoryPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period as Story.StoryPeriod?)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                if filteredStories.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("No stories yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Create journal entries and generate stories to see them here")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ForEach(filteredStories) { story in
                        Button(action: {
                            selectedStory = story
                            showingStoryDetail = true
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(story.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text(story.generationDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(story.content)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(3)
                                    .multilineTextAlignment(.leading)
                                
                                HStack {
                                    Spacer()
                                    
                                    Text("Tap to read more")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .sheet(isPresented: $showingStoryDetail) {
            if let story = selectedStory {
                storyDetailView(story: story)
            }
        }
        .sheet(isPresented: $showingEntriesList) {
            journalEntriesListView
        }
    }
    
    private func storyDetailView(story: Story) -> some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(story.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Generated on \(story.generationDate.formatted(date: .long, time: .shortened))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Period: \(story.period.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text(story.content)
                        .font(.body)
                        .lineSpacing(4)
                }
                .padding()
            }
            .navigationTitle("Story Details")
            .navigationBarItems(trailing: Button("Close") {
                showingStoryDetail = false
            })
        }
    }
    
    private var journalEntriesListView: some View {
        NavigationView {
            List {
                ForEach(viewModel.journalEntries.sorted(by: { $0.date > $1.date })) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.headline)
                            
                            Spacer()
                            
                            if let mood = entry.mood {
                                Text(mood.rawValue)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(moodColor(for: mood).opacity(0.2))
                                    .cornerRadius(8)
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
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.2))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Journal Entries")
            .navigationBarItems(trailing: Button("Close") {
                showingEntriesList = false
            })
        }
    }
    
    private func analyticCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
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
    
    private var paycheckCalculatorView: some View {
        VStack(spacing: 20) {
            Text("Paycheck Calculator")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                // Hours & Rate Input Section
                Group {
                    HStack {
                        Text("Regular Hours:")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        TextField("Hours", value: $regularHours, format: .number)
                            .keyboardType(.decimalPad)
                            .frame(width: 100)
                            .multilineTextAlignment(.trailing)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    HStack {
                        Text("Overtime Hours:")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        TextField("Hours", value: $overtimeHours, format: .number)
                            .keyboardType(.decimalPad)
                            .frame(width: 100)
                            .multilineTextAlignment(.trailing)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    HStack {
                        Text("Hourly Rate:")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        TextField("Rate", value: $hourlyRate, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .frame(width: 100)
                            .multilineTextAlignment(.trailing)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    HStack {
                        Text("Overtime Multiplier:")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Picker("", selection: $overtimeMultiplier) {
                            Text("1.5x").tag(1.5)
                            Text("2.0x").tag(2.0)
                            Text("2.5x").tag(2.5)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 150)
                    }
                }
                .padding(.vertical, 4)
                
                Divider()
                
                // Tax Settings
                Group {
                    HStack {
                        Text("Federal Tax Rate:")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Picker("", selection: $federalTaxRate) {
                            ForEach(Array(stride(from: 0.0, through: 40.0, by: 5.0)), id: \.self) { rate in
                                Text("\(Int(rate))%").tag(rate/100.0)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 100)
                    }
                    
                    HStack {
                        Text("State Tax Rate:")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Picker("", selection: $stateTaxRate) {
                            ForEach(Array(stride(from: 0.0, through: 15.0, by: 1.0)), id: \.self) { rate in
                                Text("\(Int(rate))%").tag(rate/100.0)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 100)
                    }
                    
                    Toggle("Include 401k Deduction", isOn: $include401k)
                        .font(.subheadline)
                    
                    if include401k {
                        HStack {
                            Text("401k Contribution:")
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Picker("", selection: $contribution401k) {
                                ForEach(Array(stride(from: 1.0, through: 15.0, by: 1.0)), id: \.self) { rate in
                                    Text("\(Int(rate))%").tag(rate/100.0)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 100)
                        }
                    }
                }
                .padding(.vertical, 4)
                
                Divider()
                
                // Results section
                Group {
                    PayResultRow(label: "Regular Pay", value: regularPay)
                    
                    PayResultRow(label: "Overtime Pay", value: overtimePay)
                    
                    PayResultRow(label: "Gross Pay", value: grossPay)
                        .fontWeight(.semibold)
                    
                    Divider()
                    
                    PayResultRow(label: "Federal Taxes", value: -federalTaxAmount, textColor: .red)
                    
                    PayResultRow(label: "State Taxes", value: -stateTaxAmount, textColor: .red)
                    
                    if include401k {
                        PayResultRow(label: "401k Contribution", value: -contribution401kAmount, textColor: .orange)
                    }
                    
                    Divider()
                    
                    PayResultRow(label: "Net Pay", value: netPay)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .padding(.vertical, 4)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    // Helper view for paycheck calculator
    private struct PayResultRow: View {
        var label: String
        var value: Double
        var textColor: Color = .primary
        var fontWeight: Font.Weight = .regular
        
        var body: some View {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(fontWeight)
                
                Spacer()
                
                Text(value, format: .currency(code: "USD"))
                    .font(.subheadline)
                    .fontWeight(fontWeight)
                    .foregroundColor(textColor)
            }
        }
    }
    
    // State variables for Paycheck calculator
    @State private var regularHours: Double = 40.0
    @State private var overtimeHours: Double = 0.0
    @State private var hourlyRate: Double = 20.0
    @State private var overtimeMultiplier: Double = 1.5
    @State private var federalTaxRate: Double = 0.12
    @State private var stateTaxRate: Double = 0.05
    @State private var include401k: Bool = false
    @State private var contribution401k: Double = 0.05
    
    // Computed properties for Paycheck calculator
    private var regularPay: Double {
        regularHours * hourlyRate
    }
    
    private var overtimePay: Double {
        overtimeHours * hourlyRate * overtimeMultiplier
    }
    
    private var grossPay: Double {
        regularPay + overtimePay
    }
    
    private var federalTaxAmount: Double {
        grossPay * federalTaxRate
    }
    
    private var stateTaxAmount: Double {
        grossPay * stateTaxRate
    }
    
    private var contribution401kAmount: Double {
        include401k ? grossPay * contribution401k : 0
    }
    
    private var netPay: Double {
        grossPay - federalTaxAmount - stateTaxAmount - contribution401kAmount
    }
    
    // Computed properties for Storybook feature
    private var totalWordsWritten: Int {
        viewModel.journalEntries.reduce(0) { count, entry in
            count + entry.content.split(separator: " ").count
        }
    }
    
    private var uniqueDaysJournaled: Int {
        let calendar = Calendar.current
        let uniqueDays = Set(viewModel.journalEntries.map { calendar.startOfDay(for: $0.date) })
        return uniqueDays.count
    }
    
    private var filteredStories: [Story] {
        if let period = storyFilterPeriod {
            return viewModel.stories.filter { $0.period == period }
        } else {
            return viewModel.stories
        }
    }
    
    private var goalsEditorView: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Goals Editor")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    showingGoalEditor = true
                    editingGoal = SavingsGoal(
                        name: "",
                        targetAmount: 1000.0,
                        currentAmount: 0.0,
                        targetDate: Calendar.current.date(byAdding: .month, value: 3, to: Date())
                    )
                }) {
                    Label("Add Goal", systemImage: "plus")
                        .font(.subheadline)
                }
            }
            
            if viewModel.savingsGoals.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "target")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No goals yet")
                        .font(.headline)
                    
                    Text("Add a goal to get started")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
            } else {
                ForEach(viewModel.savingsGoals) { goal in
                    GoalCardView(goal: goal) {
                        editingGoal = goal
                        showingGoalEditor = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingGoalEditor) {
            if let goal = editingGoal {
                GoalEditorView(goal: goal, isNew: goal.id == editingGoal?.id) { updatedGoal in
                    if let index = viewModel.savingsGoals.firstIndex(where: { $0.id == updatedGoal.id }) {
                        viewModel.updateSavingsGoal(updatedGoal)
                    } else {
                        viewModel.addSavingsGoal(updatedGoal)
                    }
                    showingGoalEditor = false
                } onDelete: {
                    viewModel.deleteSavingsGoal(goal)
                    showingGoalEditor = false
                } onCancel: {
                    showingGoalEditor = false
                }
            }
        }
    }
    
    private struct GoalCardView: View {
        let goal: SavingsGoal
        let onTap: () -> Void
        
        var body: some View {
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(goal.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text("$\(Int(goal.currentAmount)) / $\(Int(goal.targetAmount))")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(Int(goal.progress * 100))%")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    
                    ProgressView(value: goal.progress)
                        .tint(.blue)
                    
                    if let targetDate = goal.targetDate {
                        Text("Target: \(targetDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private struct GoalEditorView: View {
        @State private var goalName: String
        @State private var targetAmount: Double
        @State private var currentAmount: Double
        @State private var hasTargetDate: Bool
        @State private var targetDate: Date
        @State private var notes: String
        
        let isNew: Bool
        let onSave: (SavingsGoal) -> Void
        let onDelete: () -> Void
        let onCancel: () -> Void
        private let id: UUID
        
        init(goal: SavingsGoal, isNew: Bool, onSave: @escaping (SavingsGoal) -> Void, onDelete: @escaping () -> Void, onCancel: @escaping () -> Void) {
            self._goalName = State(initialValue: goal.name)
            self._targetAmount = State(initialValue: goal.targetAmount)
            self._currentAmount = State(initialValue: goal.currentAmount)
            self._hasTargetDate = State(initialValue: goal.targetDate != nil)
            self._targetDate = State(initialValue: goal.targetDate ?? Calendar.current.date(byAdding: .month, value: 3, to: Date())!)
            self._notes = State(initialValue: goal.notes ?? "")
            
            self.id = goal.id
            self.isNew = isNew
            self.onSave = onSave
            self.onDelete = onDelete
            self.onCancel = onCancel
        }
        
        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Goal Details")) {
                        TextField("Goal Name", text: $goalName)
                        
                        VStack(alignment: .leading) {
                            Text("Target Amount")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            TextField("Target Amount", value: $targetAmount, format: .currency(code: "USD"))
                                .keyboardType(.decimalPad)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Current Amount")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            TextField("Current Amount", value: $currentAmount, format: .currency(code: "USD"))
                                .keyboardType(.decimalPad)
                        }
                        
                        Toggle("Has Target Date", isOn: $hasTargetDate)
                        
                        if hasTargetDate {
                            DatePicker("Target Date", selection: $targetDate, displayedComponents: .date)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Notes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            TextEditor(text: $notes)
                                .frame(height: 100)
                        }
                    }
                    
                    if !isNew {
                        Section {
                            Button("Delete Goal", role: .destructive) {
                                onDelete()
                            }
                        }
                    }
                }
                .navigationTitle(isNew ? "New Goal" : "Edit Goal")
                .navigationBarItems(
                    leading: Button("Cancel") { onCancel() },
                    trailing: Button("Save") {
                        let updatedGoal = SavingsGoal(
                            id: id,
                            name: goalName,
                            targetAmount: targetAmount,
                            currentAmount: currentAmount,
                            targetDate: hasTargetDate ? targetDate : nil,
                            notes: notes.isEmpty ? nil : notes
                        )
                        onSave(updatedGoal)
                    }
                    .disabled(goalName.isEmpty || targetAmount <= 0)
                )
            }
        }
    }
    
    private var bucketListView: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Bucket List")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    newBucketItem = BucketListItem(title: "", description: "")
                    showingAddBucketItem = true
                }) {
                    Label("Add Item", systemImage: "plus")
                        .font(.subheadline)
                }
            }
            
            if viewModel.bucketList.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No bucket list items yet")
                        .font(.headline)
                    
                    Text("Add things you want to accomplish in your lifetime")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
            } else {
                ForEach(viewModel.bucketList.sorted(by: { !$0.isCompleted && $1.isCompleted })) { item in
                    BucketListItemView(item: item) { updatedItem in
                        viewModel.updateBucketListItem(updatedItem)
                    } onDelete: {
                        viewModel.deleteBucketListItem(item)
                    } onEdit: {
                        newBucketItem = item
                        showingAddBucketItem = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddBucketItem) {
            addBucketItemView
        }
    }
    
    private struct BucketListItemView: View {
        let item: BucketListItem
        let onToggle: (BucketListItem) -> Void
        let onDelete: () -> Void
        let onEdit: () -> Void
        
        @State private var showingOptions = false
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Button(action: {
                        var updatedItem = item
                        updatedItem.isCompleted.toggle()
                        if updatedItem.isCompleted {
                            updatedItem.completionDate = Date()
                        } else {
                            updatedItem.completionDate = nil
                        }
                        onToggle(updatedItem)
                    }) {
                        Image(systemName: item.isCompleted ? "checkmark.square.fill" : "square")
                            .foregroundColor(item.isCompleted ? .green : .gray)
                            .font(.title3)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.headline)
                            .strikethrough(item.isCompleted)
                            .foregroundColor(item.isCompleted ? .secondary : .primary)
                        
                        if let description = item.description, !description.isEmpty {
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        if let targetDate = item.targetDate {
                            Text("Target: \(targetDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let completionDate = item.completionDate {
                            Text("Completed: \(completionDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingOptions = true
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                    }
                    .padding(8)
                    .actionSheet(isPresented: $showingOptions) {
                        ActionSheet(
                            title: Text("Bucket List Item"),
                            buttons: [
                                .default(Text("Edit")) { onEdit() },
                                .destructive(Text("Delete")) { onDelete() },
                                .cancel()
                            ]
                        )
                    }
                }
                
                if let category = item.category, !category.isEmpty {
                    Text(category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                
                if item.priority > 0 {
                    HStack {
                        Text("Priority:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ForEach(1...5, id: \.self) { i in
                            Image(systemName: i <= item.priority ? "star.fill" : "star")
                                .foregroundColor(i <= item.priority ? .yellow : .gray)
                                .font(.caption)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var addBucketItemView: some View {
        NavigationView {
            Form {
                Section(header: Text("Bucket List Item")) {
                    TextField("Title", text: $newBucketItem.title)
                    
                    TextField("Description", text: Binding(
                        get: { newBucketItem.description ?? "" },
                        set: { newBucketItem.description = $0.isEmpty ? nil : $0 }
                    ))
                    .frame(height: 80)
                    
                    TextField("Category", text: Binding(
                        get: { newBucketItem.category ?? "" },
                        set: { newBucketItem.category = $0.isEmpty ? nil : $0 }
                    ))
                    
                    Toggle("Has Target Date", isOn: Binding(
                        get: { newBucketItem.targetDate != nil },
                        set: { hasDate in
                            if hasDate && newBucketItem.targetDate == nil {
                                newBucketItem.targetDate = Date()
                            } else if !hasDate {
                                newBucketItem.targetDate = nil
                            }
                        }
                    ))
                    
                    if newBucketItem.targetDate != nil {
                        DatePicker("Target Date", selection: Binding(
                            get: { newBucketItem.targetDate ?? Date() },
                            set: { newBucketItem.targetDate = $0 }
                        ), displayedComponents: .date)
                    }
                    
                    Picker("Priority", selection: $newBucketItem.priority) {
                        Text("None").tag(0)
                        ForEach(1...5, id: \.self) { priority in
                            Text("\(priority)").tag(priority)
                        }
                    }
                    
                    if newBucketItem.id != UUID() { // Editing an existing item
                        Toggle("Completed", isOn: Binding(
                            get: { newBucketItem.isCompleted },
                            set: { isCompleted in
                                newBucketItem.isCompleted = isCompleted
                                if isCompleted && newBucketItem.completionDate == nil {
                                    newBucketItem.completionDate = Date()
                                } else if !isCompleted {
                                    newBucketItem.completionDate = nil
                                }
                            }
                        ))
                        
                        if newBucketItem.isCompleted, let completionDate = newBucketItem.completionDate {
                            DatePicker("Completion Date", selection: Binding(
                                get: { completionDate },
                                set: { newBucketItem.completionDate = $0 }
                            ), displayedComponents: .date)
                        }
                    }
                }
            }
            .navigationTitle(newBucketItem.id == UUID() ? "Add Bucket List Item" : "Edit Bucket List Item")
            .navigationBarItems(
                leading: Button("Cancel") {
                    showingAddBucketItem = false
                },
                trailing: Button("Save") {
                    if newBucketItem.id == UUID() {
                        // New item
                        viewModel.addBucketListItem(newBucketItem)
                    } else {
                        // Update existing item
                        viewModel.updateBucketListItem(newBucketItem)
                    }
                    showingAddBucketItem = false
                }
                .disabled(newBucketItem.title.isEmpty)
            )
        }
    }
    
    // MARK: - Helper Functions
    
    private func toolIcon(for index: Int) -> String {
        switch index {
        case 0: // Countdown
            return "timer"
        case 1: // Storybook
            return "book.fill"
        case 2: // Paycheck Calculator
            return "dollarsign.circle.fill"
        case 3: // Goals Editor
            return "target"
        case 4: // Bucket List
            return "list.bullet.clipboard"
        case 5: // Time Remaining
            return "hourglass"
        default:
            return "questionmark"
        }
    }
}

#Preview {
    QuickToolsView()
} 