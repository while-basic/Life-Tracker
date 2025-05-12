// Created by Celaya Solutions 2025
//
//  AppModels.swift
//  Life Tracker
//
//  Created by Cursor on 5/11/25.
//

import Foundation
import SwiftUI

// This file contains all the models used throughout the Life Tracker app

// MARK: - Financial Models

struct Expense: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var amount: Double
    var dueDate: Date
    var isRecurring: Bool = false
    var recurringFrequency: Event.RecurringFrequency?
    var category: ExpenseCategory
    var notes: String?
    var isPaid: Bool = false
    
    enum ExpenseCategory: String, Codable, CaseIterable {
        case housing = "Housing"
        case utilities = "Utilities"
        case food = "Food"
        case transportation = "Transportation"
        case entertainment = "Entertainment"
        case healthcare = "Healthcare"
        case education = "Education"
        case personal = "Personal"
        case debt = "Debt"
        case other = "Other"
    }
}

struct Income: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var amount: Double
    var date: Date
    var isRecurring: Bool = false
    var recurringFrequency: Event.RecurringFrequency?
    var source: IncomeSource
    var notes: String?
    var isPaid: Bool = false
    
    enum IncomeSource: String, Codable, CaseIterable {
        case salary = "Salary"
        case freelance = "Freelance"
        case investment = "Investment"
        case gift = "Gift"
        case other = "Other"
    }
}

struct SavingsGoal: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var targetDate: Date?
    var notes: String?
    
    var progress: Double {
        return min(currentAmount / targetAmount, 1.0)
    }
}

// MARK: - Calendar Models

struct WorkShift: Identifiable, Codable {
    var id = UUID()
    var startTime: Date
    var endTime: Date
    var hourlyRate: Double
    var notes: String?
    
    var duration: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
    
    var hoursWorked: Double {
        return duration / 3600
    }
    
    var regularHours: Double {
        return min(hoursWorked, 8)
    }
    
    var overtimeHours: Double {
        return max(0, hoursWorked - 8)
    }
    
    var regularPay: Double {
        return regularHours * hourlyRate
    }
    
    var overtimePay: Double {
        return overtimeHours * hourlyRate * 1.5
    }
    
    var totalPay: Double {
        return regularPay + overtimePay
    }
}

struct Event: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var description: String?
    var startTime: Date
    var endTime: Date?
    var isAllDay: Bool = false
    var location: String?
    var category: EventCategory
    var notes: String?
    var isRecurring: Bool = false
    var recurringFrequency: RecurringFrequency?
    
    enum EventCategory: String, Codable, CaseIterable {
        case birthday = "Birthday"
        case anniversary = "Anniversary"
        case meeting = "Meeting"
        case medication = "Medication"
        case doctor = "Doctor"
        case gym = "Gym"
        case studio = "Studio"
        case general = "General"
    }
    
    enum RecurringFrequency: String, Codable, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case biweekly = "Bi-weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
    }
}

struct WorkoutSession: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var duration: TimeInterval
    var exercises: [Exercise]
    var notes: String?
    
    struct Exercise: Identifiable, Codable {
        var id = UUID()
        var name: String
        var sets: [ExerciseSet]
        
        struct ExerciseSet: Codable {
            var reps: Int
            var weight: Double?
            var duration: TimeInterval?
        }
    }
}

// MARK: - Achievement Models

struct Badge: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var description: String
    var iconName: String
    var dateEarned: Date
    var category: BadgeCategory
    
    enum BadgeCategory: String, Codable, CaseIterable {
        case financial = "Financial"
        case fitness = "Fitness"
        case personal = "Personal"
        case milestone = "Milestone"
    }
}

// MARK: - AI Models

struct AIInsight: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var description: String
    var category: InsightCategory
    var generationDate: Date
    var relatedItemIds: [UUID]? // Can reference various items
    
    enum InsightCategory: String, Codable, CaseIterable {
        case financial = "Financial"
        case health = "Health"
        case social = "Social"
        case productivity = "Productivity"
        case general = "General"
    }
}

// MARK: - Workout Model
struct Workout: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var duration: TimeInterval
    var exercises: [Exercise]
    var notes: String?
    
    struct Exercise: Identifiable, Codable {
        var id: UUID = UUID()
        var name: String
        var sets: Int
        var reps: Int
        var weight: Double?
        var notes: String?
    }
}

// MARK: - Journal Entry Model
struct JournalEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var content: String
    var mood: Mood?
    var tags: [String]?
    var associatedEvents: [UUID]? // References to Event IDs
    
    enum Mood: String, Codable, CaseIterable {
        case excellent = "Excellent"
        case good = "Good"
        case neutral = "Neutral"
        case bad = "Bad"
        case terrible = "Terrible"
    }
}

// MARK: - Story Model
struct Story: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var content: String
    var generationDate: Date
    var period: StoryPeriod
    var relatedEntryIds: [UUID]? // References to JournalEntry IDs
    
    enum StoryPeriod: String, Codable, CaseIterable {
        case weekly = "Weekly"
        case monthly = "Monthly"
        case quarterly = "Quarterly"
        case yearly = "Yearly"
    }
}

// MARK: - Bucket List Item Model
struct BucketListItem: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var description: String?
    var isCompleted: Bool = false
    var targetDate: Date?
    var completionDate: Date?
    var category: String?
    var priority: Int = 1 // 1-5 scale
} 