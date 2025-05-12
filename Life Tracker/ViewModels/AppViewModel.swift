// Created by Celaya Solutions 2025
//
//  AppViewModel.swift
//  Life Tracker
//

import Foundation
import SwiftUI
import Combine
import UserNotifications

class AppViewModel: ObservableObject {
    // MARK: - Published Properties
    
    // Financial
    @Published var expenses: [Expense] = []
    @Published var incomes: [Income] = []
    @Published var savingsGoals: [SavingsGoal] = []
    
    // Calendar
    @Published var workShifts: [WorkShift] = []
    @Published var events: [Event] = []
    @Published var workoutSessions: [WorkoutSession] = []
    
    // Achievements
    @Published var badges: [Badge] = []
    
    // AI Insights
    @Published var insights: [AIInsight] = []
    
    // Journal
    @Published var journalEntries: [JournalEntry] = []
    
    // Stories
    @Published var stories: [Story] = []
    
    // Bucket List
    @Published var bucketList: [BucketListItem] = []
    
    // Auto-refresh timer
    private var refreshTimer: Timer?
    
    // MARK: - Computed Properties
    
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var totalIncome: Double {
        incomes.reduce(0) { $0 + $1.amount }
    }
    
    var netWorth: Double {
        totalIncome - totalExpenses + totalSavings
    }
    
    var totalSavings: Double {
        savingsGoals.reduce(0) { $0 + $1.currentAmount }
    }
    
    var upcomingEvents: [Event] {
        let now = Date()
        let oneWeekLater = Calendar.current.date(byAdding: .day, value: 7, to: now)!
        
        return events
            .filter { $0.startTime >= now && $0.startTime <= oneWeekLater }
            .sorted { $0.startTime < $1.startTime }
    }
    
    var upcomingExpenses: [Expense] {
        let now = Date()
        let oneWeekLater = Calendar.current.date(byAdding: .day, value: 7, to: now)!
        
        return expenses
            .filter { !$0.isPaid && $0.dueDate >= now && $0.dueDate <= oneWeekLater }
            .sorted { $0.dueDate < $1.dueDate }
    }
    
    // MARK: - Init
    
    init() {
        loadData()
        
        // We no longer add sample data automatically
        // The user will enter their own data
        
        // Set up a refresh timer to update the UI every 5 minutes
        setupRefreshTimer()
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
    
    // Set up a timer to update the UI periodically
    private func setupRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.refreshData()
        }
    }
    
    // Refresh data and update the UI
    func refreshData() {
        // This forces a UI update by sending an objectWillChange notification
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
        
        // Check if any smart alerts need to be triggered
        NotificationManager.shared.analyzeAndScheduleSmartAlerts(viewModel: self)
    }
    
    // MARK: - Data Management
    
    func loadData() {
        // Load expenses
        if let data = UserDefaults.standard.data(forKey: "expenses") {
            if let decoded = try? JSONDecoder().decode([Expense].self, from: data) {
                expenses = decoded
            }
        }
        
        // Load incomes
        if let data = UserDefaults.standard.data(forKey: "incomes") {
            if let decoded = try? JSONDecoder().decode([Income].self, from: data) {
                incomes = decoded
            }
        }
        
        // Load savings goals
        if let data = UserDefaults.standard.data(forKey: "savingsGoals") {
            if let decoded = try? JSONDecoder().decode([SavingsGoal].self, from: data) {
                savingsGoals = decoded
            }
        }
        
        // Load events
        if let data = UserDefaults.standard.data(forKey: "events") {
            if let decoded = try? JSONDecoder().decode([Event].self, from: data) {
                events = decoded
            }
        }
        
        // Load work shifts
        if let data = UserDefaults.standard.data(forKey: "workShifts") {
            if let decoded = try? JSONDecoder().decode([WorkShift].self, from: data) {
                workShifts = decoded
            }
        }
        
        // Load workout sessions
        if let data = UserDefaults.standard.data(forKey: "workoutSessions") {
            if let decoded = try? JSONDecoder().decode([WorkoutSession].self, from: data) {
                workoutSessions = decoded
            }
        }
        
        // Load badges
        if let data = UserDefaults.standard.data(forKey: "badges") {
            if let decoded = try? JSONDecoder().decode([Badge].self, from: data) {
                badges = decoded
            }
        }
        
        // Load insights
        if let data = UserDefaults.standard.data(forKey: "insights") {
            if let decoded = try? JSONDecoder().decode([AIInsight].self, from: data) {
                insights = decoded
            }
        }
        
        // Load journal entries
        if let data = UserDefaults.standard.data(forKey: "journalEntries") {
            if let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
                journalEntries = decoded
            }
        }
        
        // Load stories
        if let data = UserDefaults.standard.data(forKey: "stories") {
            if let decoded = try? JSONDecoder().decode([Story].self, from: data) {
                stories = decoded
            }
        }
        
        // Load bucket list items
        if let data = UserDefaults.standard.data(forKey: "bucketList") {
            if let decoded = try? JSONDecoder().decode([BucketListItem].self, from: data) {
                bucketList = decoded
            }
        }
    }
    
    func saveData() {
        // Save expenses
        if let encoded = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: "expenses")
        }
        
        // Save incomes
        if let encoded = try? JSONEncoder().encode(incomes) {
            UserDefaults.standard.set(encoded, forKey: "incomes")
        }
        
        // Save savings goals
        if let encoded = try? JSONEncoder().encode(savingsGoals) {
            UserDefaults.standard.set(encoded, forKey: "savingsGoals")
        }
        
        // Save events
        if let encoded = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(encoded, forKey: "events")
        }
        
        // Save work shifts
        if let encoded = try? JSONEncoder().encode(workShifts) {
            UserDefaults.standard.set(encoded, forKey: "workShifts")
        }
        
        // Save workout sessions
        if let encoded = try? JSONEncoder().encode(workoutSessions) {
            UserDefaults.standard.set(encoded, forKey: "workoutSessions")
        }
        
        // Save badges
        if let encoded = try? JSONEncoder().encode(badges) {
            UserDefaults.standard.set(encoded, forKey: "badges")
        }
        
        // Save insights
        if let encoded = try? JSONEncoder().encode(insights) {
            UserDefaults.standard.set(encoded, forKey: "insights")
        }
        
        // Save journal entries
        if let encoded = try? JSONEncoder().encode(journalEntries) {
            UserDefaults.standard.set(encoded, forKey: "journalEntries")
        }
        
        // Save stories
        if let encoded = try? JSONEncoder().encode(stories) {
            UserDefaults.standard.set(encoded, forKey: "stories")
        }
        
        // Save bucket list items
        if let encoded = try? JSONEncoder().encode(bucketList) {
            UserDefaults.standard.set(encoded, forKey: "bucketList")
        }
    }
    
    // MARK: - Data Manipulation
    
    // Expense methods
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        saveData()
        
        // Update upcoming expenses
        objectWillChange.send()
        
        // Schedule notification
        NotificationManager.shared.scheduleExpenseReminder(for: expense)
    }
    
    func updateExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
            saveData()
            
            // Update upcoming expenses
            objectWillChange.send()
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
        saveData()
    }
    
    // Income methods
    func addIncome(_ income: Income) {
        incomes.append(income)
        saveData()
    }
    
    func updateIncome(_ income: Income) {
        if let index = incomes.firstIndex(where: { $0.id == income.id }) {
            incomes[index] = income
            saveData()
        }
    }
    
    func deleteIncome(_ income: Income) {
        incomes.removeAll { $0.id == income.id }
        saveData()
    }
    
    // Event methods
    func addEvent(_ event: Event) {
        events.append(event)
        saveData()
        
        // Update upcoming events
        objectWillChange.send()
        
        // Schedule notifications for specific event types
        if event.category == .birthday {
            NotificationManager.shared.scheduleBirthdayReminder(for: event)
        } else if event.category == .anniversary {
            NotificationManager.shared.scheduleAnniversaryReminder(for: event)
        } else {
            NotificationManager.shared.scheduleEventReminder(for: event)
        }
    }
    
    func updateEvent(_ event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            // Cancel existing notification
            NotificationManager.shared.cancelNotification(withIdentifier: "event-\(event.id.uuidString)")
            
            // Update event
            events[index] = event
            saveData()
            
            // Reschedule notifications
            if event.category == .birthday {
                NotificationManager.shared.scheduleBirthdayReminder(for: event)
            } else if event.category == .anniversary {
                NotificationManager.shared.scheduleAnniversaryReminder(for: event)
            } else {
                NotificationManager.shared.scheduleEventReminder(for: event)
            }
        }
    }
    
    func deleteEvent(_ event: Event) {
        // Cancel notification
        NotificationManager.shared.cancelNotification(withIdentifier: "event-\(event.id.uuidString)")
        
        // Remove event
        events.removeAll { $0.id == event.id }
        saveData()
    }
    
    // Work shift methods
    func addWorkShift(_ shift: WorkShift) {
        workShifts.append(shift)
        saveData()
    }
    
    func updateWorkShift(_ shift: WorkShift) {
        if let index = workShifts.firstIndex(where: { $0.id == shift.id }) {
            workShifts[index] = shift
            saveData()
        }
    }
    
    func deleteWorkShift(_ shift: WorkShift) {
        workShifts.removeAll { $0.id == shift.id }
        saveData()
    }
    
    // Workout session methods
    func addWorkoutSession(_ session: WorkoutSession) {
        workoutSessions.append(session)
        saveData()
        
        // Check for workout streaks and award badges if necessary
        checkForWorkoutStreak()
    }
    
    func updateWorkoutSession(_ session: WorkoutSession) {
        if let index = workoutSessions.firstIndex(where: { $0.id == session.id }) {
            workoutSessions[index] = session
            saveData()
        }
    }
    
    func deleteWorkoutSession(_ session: WorkoutSession) {
        workoutSessions.removeAll { $0.id == session.id }
        saveData()
    }
    
    // Savings goal methods
    func addSavingsGoal(_ goal: SavingsGoal) {
        savingsGoals.append(goal)
        saveData()
        
        // Update goals display
        objectWillChange.send()
    }
    
    func updateSavingsGoal(_ goal: SavingsGoal) {
        if let index = savingsGoals.firstIndex(where: { $0.id == goal.id }) {
            let oldGoal = savingsGoals[index]
            savingsGoals[index] = goal
            saveData()
            
            // Update goals display
            objectWillChange.send()
            
            // Check if we've hit a milestone
            if oldGoal.progress < 0.5 && goal.progress >= 0.5 {
                NotificationManager.shared.scheduleGoalMilestone(for: goal, milestonePercentage: 50)
            } else if oldGoal.progress < 0.75 && goal.progress >= 0.75 {
                NotificationManager.shared.scheduleGoalMilestone(for: goal, milestonePercentage: 75)
            } else if oldGoal.progress < 1.0 && goal.progress >= 1.0 {
                NotificationManager.shared.scheduleGoalMilestone(for: goal, milestonePercentage: 100)
                
                // Award a badge for completing a savings goal
                let badge = Badge(
                    name: "Goal Achieved",
                    description: "Completed savings goal: \(goal.name)",
                    iconName: "star.fill",
                    dateEarned: Date(),
                    category: .financial
                )
                awardBadge(badge)
            }
        }
    }
    
    func deleteSavingsGoal(_ goal: SavingsGoal) {
        savingsGoals.removeAll { $0.id == goal.id }
        saveData()
    }
    
    // Journal entry methods
    func addJournalEntry(_ entry: JournalEntry) {
        journalEntries.append(entry)
        saveData()
    }
    
    func updateJournalEntry(_ entry: JournalEntry) {
        if let index = journalEntries.firstIndex(where: { $0.id == entry.id }) {
            journalEntries[index] = entry
            saveData()
        }
    }
    
    func deleteJournalEntry(_ entry: JournalEntry) {
        journalEntries.removeAll { $0.id == entry.id }
        saveData()
    }
    
    // Story methods
    func addStory(_ story: Story) {
        stories.append(story)
        saveData()
        
        // Notify user of new story
        NotificationManager.shared.scheduleStoryNotification(storyTitle: story.title, storyType: story.period.rawValue)
    }
    
    func updateStory(_ story: Story) {
        if let index = stories.firstIndex(where: { $0.id == story.id }) {
            stories[index] = story
            saveData()
        }
    }
    
    func deleteStory(_ story: Story) {
        stories.removeAll { $0.id == story.id }
        saveData()
    }
    
    // Bucket list item methods
    func addBucketListItem(_ item: BucketListItem) {
        bucketList.append(item)
        saveData()
    }
    
    func updateBucketListItem(_ item: BucketListItem) {
        if let index = bucketList.firstIndex(where: { $0.id == item.id }) {
            bucketList[index] = item
            saveData()
        }
    }
    
    func deleteBucketListItem(_ item: BucketListItem) {
        bucketList.removeAll { $0.id == item.id }
        saveData()
    }
    
    // MARK: - Achievement Tracking
    
    func checkForWorkoutStreak() {
        // Sort workout sessions by date
        let sortedSessions = workoutSessions.sorted { $0.date < $1.date }
        
        // Check for a streak of at least 5 consecutive days
        var currentStreak = 1
        var maxStreak = 1
        
        for i in 1..<sortedSessions.count {
            let previousDate = Calendar.current.startOfDay(for: sortedSessions[i-1].date)
            let currentDate = Calendar.current.startOfDay(for: sortedSessions[i].date)
            
            if let dayDifference = Calendar.current.dateComponents([.day], from: previousDate, to: currentDate).day, dayDifference == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else if let dayDifference = Calendar.current.dateComponents([.day], from: previousDate, to: currentDate).day, dayDifference > 1 {
                currentStreak = 1
            }
        }
        
        // Award badges based on streak milestones
        if maxStreak >= 5 && !hasBadge(named: "5-Day Streak") {
            let badge = Badge(
                name: "5-Day Streak",
                description: "Worked out for 5 consecutive days",
                iconName: "flame.fill",
                dateEarned: Date(),
                category: .fitness
            )
            awardBadge(badge)
        }
        
        if maxStreak >= 10 && !hasBadge(named: "10-Day Streak") {
            let badge = Badge(
                name: "10-Day Streak",
                description: "Worked out for 10 consecutive days",
                iconName: "flame.fill",
                dateEarned: Date(),
                category: .fitness
            )
            awardBadge(badge)
        }
    }
    
    func hasBadge(named name: String) -> Bool {
        return badges.contains { $0.name == name }
    }
    
    func awardBadge(_ badge: Badge) {
        badges.append(badge)
        saveData()
    }
    
    // MARK: - AI Features
    
    func generateInsights() {
        // This method will be called when the user requests insights
        // In a real app, this would call OpenAI API based on user data
        
        // For now, we'll create an insight based on current data
        let insightTitle = "Financial Summary"
        let insightDescription = "Based on your current data, here's a summary of your financial situation."
        
        let insight = AIInsight(
            id: UUID(),
            title: insightTitle,
            description: insightDescription,
            category: .financial,
            generationDate: Date(),
            relatedItemIds: nil
        )
        
        insights.append(insight)
        saveData()
    }
    
    func generateStory(for period: Story.StoryPeriod) {
        // This method will be called when the user requests a story
        // In a real app, this would call OpenAI API based on user's journal entries
        
        let title = "Your \(period.rawValue) Story"
        let content = "This is a placeholder for your \(period.rawValue.lowercased()) story. In the future, this will be generated based on your journal entries and activities."
        
        let story = Story(
            id: UUID(),
            title: title,
            content: content,
            generationDate: Date(),
            period: period,
            relatedEntryIds: nil
        )
        
        stories.append(story)
        saveData()
        
        // Notify user of new story
        NotificationManager.shared.scheduleStoryNotification(storyTitle: title, storyType: period.rawValue)
    }
    
    // MARK: - Data Management
    
    // Sample data has been removed to allow users to enter their own data
    // The app now uses UserDefaults for persistent storage
} 