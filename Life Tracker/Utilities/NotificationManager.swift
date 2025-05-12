// Created by Celaya Solutions 2025
//
//  NotificationManager.swift
//  Life Tracker
//
import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Permission Management
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // MARK: - Smart Alerts
    
    func analyzeAndScheduleSmartAlerts(viewModel: AppViewModel) {
        // Analyze financial patterns
        analyzeFinancialPatterns(viewModel: viewModel)
        
        // Analyze upcoming events
        analyzeUpcomingEvents(viewModel: viewModel)
        
        // Analyze workout patterns
        analyzeWorkoutPatterns(viewModel: viewModel)
        
        // Analyze savings goals progress
        analyzeGoalsProgress(viewModel: viewModel)
        
        // Analyze journal patterns
        analyzeJournalPatterns(viewModel: viewModel)
    }
    
    private func analyzeFinancialPatterns(viewModel: AppViewModel) {
        // Detect upcoming bills that might cause negative balance
        let upcomingExpenses = viewModel.expenses.filter {
            !$0.isPaid && 
            $0.dueDate > Date() && 
            $0.dueDate < Calendar.current.date(byAdding: .day, value: 14, to: Date())!
        }
        
        let totalUpcomingExpenses = upcomingExpenses.reduce(0) { $0 + $1.amount }
        
        // Check if there's a potential shortfall
        if totalUpcomingExpenses > viewModel.totalIncome * 0.8 {
            let content = UNMutableNotificationContent()
            content.title = "Financial Alert"
            content.body = "You have $\(String(format: "%.2f", totalUpcomingExpenses)) in upcoming expenses in the next 14 days. This is \(Int(totalUpcomingExpenses / viewModel.totalIncome * 100))% of your monthly income."
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
            let request = UNNotificationRequest(
                identifier: "financial-alert-\(UUID().uuidString)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request)
        }
        
        // Detect recurring expenses that haven't been scheduled
        for expense in viewModel.expenses {
            if expense.isRecurring, 
               let frequency = expense.recurringFrequency,
               !expense.isPaid,
               expense.dueDate < Date() {
                
                // Calculate next occurrence based on frequency
                var nextDueDate: Date?
                switch frequency {
                case .daily:
                    nextDueDate = Calendar.current.date(byAdding: .day, value: 1, to: expense.dueDate)
                case .weekly:
                    nextDueDate = Calendar.current.date(byAdding: .day, value: 7, to: expense.dueDate)
                case .biweekly:
                    nextDueDate = Calendar.current.date(byAdding: .day, value: 14, to: expense.dueDate)
                case .monthly:
                    nextDueDate = Calendar.current.date(byAdding: .month, value: 1, to: expense.dueDate)
                case .yearly:
                    nextDueDate = Calendar.current.date(byAdding: .year, value: 1, to: expense.dueDate)
                }
                
                if let nextDueDate = nextDueDate {
                    let content = UNMutableNotificationContent()
                    content.title = "Recurring Expense"
                    content.body = "Your recurring expense '\(expense.name)' for $\(String(format: "%.2f", expense.amount)) needs to be scheduled for \(nextDueDate.formatted(date: .abbreviated, time: .omitted))."
                    content.sound = .default
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 120, repeats: false)
                    let request = UNNotificationRequest(
                        identifier: "recurring-expense-\(UUID().uuidString)",
                        content: content,
                        trigger: trigger
                    )
                    
                    UNUserNotificationCenter.current().add(request)
                }
            }
        }
    }
    
    private func analyzeUpcomingEvents(viewModel: AppViewModel) {
        // Detect calendar conflicts
        let upcomingEvents = viewModel.events.filter {
            $0.startTime > Date() && 
            $0.startTime < Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        }.sorted { $0.startTime < $1.startTime }
        
        // Check for overlapping events
        for i in 0..<upcomingEvents.count-1 {
            let event1 = upcomingEvents[i]
            let event2 = upcomingEvents[i+1]
            
            // If event1 has no end time, assume it's 1 hour long
            let event1End = event1.endTime ?? Calendar.current.date(byAdding: .hour, value: 1, to: event1.startTime)!
            
            if event1End > event2.startTime {
                // Events overlap
                let content = UNMutableNotificationContent()
                content.title = "Schedule Conflict"
                content.body = "'\(event1.title)' and '\(event2.title)' have a scheduling conflict on \(event1.startTime.formatted(date: .abbreviated, time: .shortened))."
                content.sound = .default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 180, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "event-conflict-\(UUID().uuidString)",
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request)
            }
        }
        
        // Check for busy days with too many events
        let calendar = Calendar.current
        var eventsByDay: [Date: [Event]] = [:]
        
        for event in upcomingEvents {
            let startOfDay = calendar.startOfDay(for: event.startTime)
            if eventsByDay[startOfDay] != nil {
                eventsByDay[startOfDay]?.append(event)
            } else {
                eventsByDay[startOfDay] = [event]
            }
        }
        
        for (day, events) in eventsByDay {
            if events.count >= 4 {
                let content = UNMutableNotificationContent()
                content.title = "Busy Day Alert"
                content.body = "You have \(events.count) events scheduled for \(day.formatted(date: .long, time: .omitted)). Consider rescheduling some events."
                content.sound = .default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 240, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "busy-day-\(UUID().uuidString)",
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    private func analyzeWorkoutPatterns(viewModel: AppViewModel) {
        // Check for workout consistency
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: today) else { return }
        
        let recentWorkouts = viewModel.workoutSessions.filter {
            let sessionDate = calendar.startOfDay(for: $0.date)
            return sessionDate >= oneWeekAgo && sessionDate <= today
        }
        
        // If no workouts in the last week, send a reminder
        if recentWorkouts.isEmpty {
            let content = UNMutableNotificationContent()
            content.title = "Workout Reminder"
            content.body = "You haven't logged any workouts in the past week. Stay active to meet your fitness goals!"
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 300, repeats: false)
            let request = UNNotificationRequest(
                identifier: "workout-reminder-\(UUID().uuidString)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request)
        }
        
        // Check if user typically works out on specific days
        if let lastWorkout = viewModel.workoutSessions.max(by: { $0.date < $1.date }) {
            let lastWorkoutDay = calendar.startOfDay(for: lastWorkout.date)
            let daysSinceLastWorkout = calendar.dateComponents([.day], from: lastWorkoutDay, to: today).day ?? 0
            
            // If it's been 3+ days since last workout
            if daysSinceLastWorkout >= 3 {
                let content = UNMutableNotificationContent()
                content.title = "Workout Streak at Risk"
                content.body = "It's been \(daysSinceLastWorkout) days since your last workout. Don't break your streak!"
                content.sound = .default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 360, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "workout-streak-\(UUID().uuidString)",
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    private func analyzeGoalsProgress(viewModel: AppViewModel) {
        // Check for stalled goals
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        for goal in viewModel.savingsGoals {
            // If the goal has a target date
            if let targetDate = goal.targetDate {
                let daysUntilDeadline = calendar.dateComponents([.day], from: today, to: targetDate).day ?? 0
                
                // If goal is less than 50% complete and deadline is approaching
                if goal.progress < 0.5 && daysUntilDeadline < 30 && daysUntilDeadline > 0 {
                    let content = UNMutableNotificationContent()
                    content.title = "Goal Progress Alert"
                    content.body = "Your goal '\(goal.name)' is only \(Int(goal.progress * 100))% complete with \(daysUntilDeadline) days remaining until your target date."
                    content.sound = .default
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 420, repeats: false)
                    let request = UNNotificationRequest(
                        identifier: "goal-progress-\(UUID().uuidString)",
                        content: content,
                        trigger: trigger
                    )
                    
                    UNUserNotificationCenter.current().add(request)
                }
            }
        }
    }
    
    private func analyzeJournalPatterns(viewModel: AppViewModel) {
        // Check journal consistency
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: today) else { return }
        
        let recentEntries = viewModel.journalEntries.filter {
            let entryDate = calendar.startOfDay(for: $0.date)
            return entryDate >= oneWeekAgo && entryDate <= today
        }
        
        // If user has been journaling regularly but missed a few days
        if recentEntries.count >= 3 && recentEntries.count < 7 {
            // Check if there was no entry yesterday
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return }
            
            let yesterdayEntry = recentEntries.first {
                calendar.startOfDay(for: $0.date) == yesterday
            }
            
            if yesterdayEntry == nil {
                let content = UNMutableNotificationContent()
                content.title = "Journal Reminder"
                content.body = "You missed your journal entry yesterday. Keep up your journaling habit!"
                content.sound = .default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 480, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "journal-reminder-\(UUID().uuidString)",
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    // MARK: - Standard Notifications
    
    func scheduleEventReminder(for event: Event, daysInAdvance: Int = 1) {
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Event"
        content.body = "\(event.title) is coming up in \(daysInAdvance) day(s)"
        content.sound = .default
        
        // Calculate notification date
        guard let notificationDate = Calendar.current.date(byAdding: .day, value: -daysInAdvance, to: event.startTime) else {
            return
        }
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "event-\(event.id.uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func scheduleExpenseReminder(for expense: Expense, daysInAdvance: Int = 2) {
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Expense"
        content.body = "\(expense.name) ($\(String(format: "%.2f", expense.amount))) is due in \(daysInAdvance) day(s)"
        content.sound = .default
        
        // Calculate notification date
        guard let notificationDate = Calendar.current.date(byAdding: .day, value: -daysInAdvance, to: expense.dueDate) else {
            return
        }
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "expense-\(expense.id.uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func scheduleGoalMilestone(for goal: SavingsGoal, milestonePercentage: Int = 50) {
        let content = UNMutableNotificationContent()
        content.title = "Goal Milestone"
        content.body = "Congratulations! You've reached \(milestonePercentage)% of your \(goal.name) goal!"
        content.sound = .default
        
        // This would be triggered when the user updates their goal progress
        // For now, we'll just set up the notification request
        let request = UNNotificationRequest(identifier: "goal-\(goal.id.uuidString)-\(milestonePercentage)", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func scheduleBirthdayReminder(for event: Event, daysInAdvance: Int = 7) {
        guard event.category == .birthday else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Birthday"
        content.body = "\(event.title) is in \(daysInAdvance) days. Have you bought a present?"
        content.sound = .default
        
        // Calculate notification date
        guard let notificationDate = Calendar.current.date(byAdding: .day, value: -daysInAdvance, to: event.startTime) else {
            return
        }
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "birthday-\(event.id.uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func scheduleAnniversaryReminder(for event: Event, daysInAdvance: Int = 7) {
        guard event.category == .anniversary else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Anniversary"
        content.body = "Your \(event.title) is in \(daysInAdvance) days."
        content.sound = .default
        
        // Calculate notification date
        guard let notificationDate = Calendar.current.date(byAdding: .day, value: -daysInAdvance, to: event.startTime) else {
            return
        }
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "anniversary-\(event.id.uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func scheduleStoryNotification(storyTitle: String, storyType: String) {
        let content = UNMutableNotificationContent()
        content.title = "New Story Generated"
        content.body = "Your \(storyType) story '\(storyTitle)' is ready to read!"
        content.sound = .default
        
        // Deliver immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "story-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling story notification: \(error)")
            }
        }
    }
    
    func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
} 