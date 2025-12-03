// Created by Celaya Solutions 2025
//
//  AICompanionModels.swift
//  Life Tracker
//

import Foundation
import SwiftUI
import HealthKit

// MARK: - AI Companion Mode

enum AIMode: String, CaseIterable, Codable {
    case casualChat = "Casual Chat"
    case planning = "Planning"
    case acting = "Acting"
    case review = "Review"
    case chess = "Chess Mode"
    case confidence = "Confidence Mode"

    var icon: String {
        switch self {
        case .casualChat: return "bubble.left.and.bubble.right"
        case .planning: return "lightbulb.fill"
        case .acting: return "figure.walk"
        case .review: return "chart.line.uptrend.xyaxis"
        case .chess: return "crown.fill"
        case .confidence: return "lock.shield"
        }
    }

    var color: Color {
        switch self {
        case .casualChat: return .blue
        case .planning: return .orange
        case .acting: return .green
        case .review: return .purple
        case .chess: return .yellow
        case .confidence: return .gray
        }
    }

    var description: String {
        switch self {
        case .casualChat: return "Natural conversation and general assistance"
        case .planning: return "Brainstorming, preparation, strategic thinking"
        case .acting: return "Step-by-step execution coaching"
        case .review: return "Retrospective analysis of patterns and decisions"
        case .chess: return "Strategic analysis using all available data"
        case .confidence: return "Privacy mode - nothing is remembered"
        }
    }
}

// MARK: - Conversation Models

struct ConversationMessage: Identifiable, Codable {
    var id: UUID = UUID()
    var role: MessageRole
    var content: String
    var timestamp: Date
    var mode: AIMode
    var sentimentScore: Double? // -1.0 (negative) to 1.0 (positive)
    var healthDataSnapshot: HealthDataSnapshot?

    enum MessageRole: String, Codable {
        case user
        case assistant
        case system
    }
}

struct Conversation: Identifiable, Codable {
    var id: UUID = UUID()
    var mode: AIMode
    var messages: [ConversationMessage]
    var startDate: Date
    var endDate: Date?
    var title: String?
    var summary: String?
}

// MARK: - Health Data Models

struct HealthDataSnapshot: Codable {
    var timestamp: Date
    var heartRate: Double?
    var steps: Int?
    var sleepHours: Double?
    var activeEnergyBurned: Double?
    var stressLevel: Double? // Derived from HRV
    var mood: String?
}

struct HealthData: Codable {
    var heartRateData: [HealthDataPoint] = []
    var stepsData: [HealthDataPoint] = []
    var sleepData: [HealthDataPoint] = []
    var activityData: [HealthDataPoint] = []
    var hrvData: [HealthDataPoint] = [] // Heart Rate Variability for stress

    struct HealthDataPoint: Codable, Identifiable {
        var id: UUID = UUID()
        var date: Date
        var value: Double
    }

    func latestSnapshot() -> HealthDataSnapshot {
        return HealthDataSnapshot(
            timestamp: Date(),
            heartRate: heartRateData.last?.value,
            steps: Int(stepsData.last?.value ?? 0),
            sleepHours: sleepData.last?.value,
            activeEnergyBurned: activityData.last?.value,
            stressLevel: calculateStressLevel(),
            mood: nil
        )
    }

    private func calculateStressLevel() -> Double? {
        guard let latestHRV = hrvData.last?.value else { return nil }
        // Lower HRV = Higher stress
        // Normalize to 0-1 scale (assuming HRV range 20-100)
        let normalizedStress = 1.0 - ((latestHRV - 20) / 80)
        return max(0, min(1, normalizedStress))
    }
}

// MARK: - Psychoanalysis Models

struct PsychoanalysisData: Codable {
    var sentimentHistory: [SentimentDataPoint] = []
    var wordFrequency: [String: Int] = [:]
    var communicationPatterns: CommunicationPatterns = CommunicationPatterns()
    var moodCorrelations: [MoodCorrelation] = []

    struct SentimentDataPoint: Codable, Identifiable {
        var id: UUID = UUID()
        var timestamp: Date
        var sentiment: Double // -1.0 to 1.0
        var mode: AIMode
        var healthSnapshot: HealthDataSnapshot?
    }

    struct CommunicationPatterns: Codable {
        var averageMessageLength: Double = 0
        var formalityScore: Double = 0 // 0 = very casual, 1 = very formal
        var complexityScore: Double = 0 // Based on vocabulary richness
        var conversationFrequency: [String: Int] = [:] // Day of week -> count
        var preferredModes: [AIMode: Int] = [:]
    }

    struct MoodCorrelation: Codable, Identifiable {
        var id: UUID = UUID()
        var date: Date
        var mood: String
        var sentiment: Double
        var heartRate: Double?
        var steps: Int?
        var sleepHours: Double?
    }

    mutating func addMessage(_ message: ConversationMessage, healthSnapshot: HealthDataSnapshot?) {
        // Add sentiment data point
        if let sentiment = message.sentimentScore {
            let dataPoint = SentimentDataPoint(
                timestamp: message.timestamp,
                sentiment: sentiment,
                mode: message.mode,
                healthSnapshot: healthSnapshot
            )
            sentimentHistory.append(dataPoint)
        }

        // Update word frequency
        let words = message.content.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 3 } // Filter out short words

        for word in words {
            wordFrequency[word, default: 0] += 1
        }

        // Update communication patterns
        updateCommunicationPatterns(message: message)
    }

    private mutating func updateCommunicationPatterns(message: ConversationMessage) {
        // Update average message length
        let currentTotal = communicationPatterns.averageMessageLength * Double(sentimentHistory.count)
        communicationPatterns.averageMessageLength = (currentTotal + Double(message.content.count)) / Double(sentimentHistory.count + 1)

        // Update preferred modes
        communicationPatterns.preferredModes[message.mode, default: 0] += 1

        // Update conversation frequency (day of week)
        let dayOfWeek = Calendar.current.component(.weekday, from: message.timestamp)
        let dayName = DateFormatter().weekdaySymbols[dayOfWeek - 1]
        communicationPatterns.conversationFrequency[dayName, default: 0] += 1

        // Calculate formality score (basic heuristic)
        let formalWords = ["please", "thank you", "kindly", "regards", "sincerely"]
        let casualWords = ["yeah", "nah", "ok", "cool", "awesome"]
        let lowercased = message.content.lowercased()

        var formalCount = 0
        var casualCount = 0

        for word in formalWords {
            if lowercased.contains(word) { formalCount += 1 }
        }

        for word in casualWords {
            if lowercased.contains(word) { casualCount += 1 }
        }

        if formalCount + casualCount > 0 {
            let newFormality = Double(formalCount) / Double(formalCount + casualCount)
            communicationPatterns.formalityScore = (communicationPatterns.formalityScore + newFormality) / 2
        }
    }

    func getMostFrequentWords(limit: Int = 20) -> [(word: String, count: Int)] {
        return wordFrequency.sorted { $0.value > $1.value }.prefix(limit).map { ($0.key, $0.value) }
    }

    func getAverageSentiment() -> Double {
        guard !sentimentHistory.isEmpty else { return 0 }
        return sentimentHistory.reduce(0) { $0 + $1.sentiment } / Double(sentimentHistory.count)
    }

    func getSentimentTrend(days: Int = 7) -> [SentimentDataPoint] {
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return sentimentHistory.filter { $0.timestamp >= startDate }
    }
}

// MARK: - Prompt Library Models

struct Prompt: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var content: String
    var category: PromptCategory
    var mode: AIMode
    var isBuiltIn: Bool = false
    var createdDate: Date
    var lastUsedDate: Date?
    var usageCount: Int = 0
    var tags: [String] = []

    enum PromptCategory: String, Codable, CaseIterable {
        case productivity = "Productivity"
        case wellness = "Wellness"
        case business = "Business"
        case personal = "Personal"
        case creative = "Creative"
        case analysis = "Analysis"
        case custom = "Custom"
    }
}

struct PromptLibrary: Codable {
    var prompts: [Prompt] = []

    mutating func addPrompt(_ prompt: Prompt) {
        prompts.append(prompt)
    }

    mutating func updatePrompt(_ prompt: Prompt) {
        if let index = prompts.firstIndex(where: { $0.id == prompt.id }) {
            prompts[index] = prompt
        }
    }

    mutating func deletePrompt(_ prompt: Prompt) {
        prompts.removeAll { $0.id == prompt.id }
    }

    mutating func usePrompt(_ promptId: UUID) {
        if let index = prompts.firstIndex(where: { $0.id == promptId }) {
            prompts[index].usageCount += 1
            prompts[index].lastUsedDate = Date()
        }
    }

    func getPrompts(for mode: AIMode) -> [Prompt] {
        return prompts.filter { $0.mode == mode }
    }

    func getPrompts(for category: Prompt.PromptCategory) -> [Prompt] {
        return prompts.filter { $0.category == category }
    }

    func searchPrompts(query: String) -> [Prompt] {
        return prompts.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.content.localizedCaseInsensitiveContains(query) ||
            $0.tags.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
}

// MARK: - User Analytics

struct UserAnalytics: Codable {
    var totalConversations: Int = 0
    var totalMessages: Int = 0
    var modeUsage: [AIMode: Int] = [:]
    var averageSessionDuration: TimeInterval = 0
    var mostActiveTime: String = ""
    var streakDays: Int = 0
    var lastActiveDate: Date?

    mutating func recordConversation(_ conversation: Conversation) {
        totalConversations += 1
        totalMessages += conversation.messages.count
        modeUsage[conversation.mode, default: 0] += 1

        // Update streak
        if let lastDate = lastActiveDate {
            let calendar = Calendar.current
            if calendar.isDateInToday(lastDate) || calendar.isDateInYesterday(lastDate) {
                if !calendar.isDateInToday(lastDate) {
                    streakDays += 1
                }
            } else {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }

        lastActiveDate = Date()
    }

    func getMostUsedMode() -> AIMode? {
        return modeUsage.max(by: { $0.value < $1.value })?.key
    }
}

// MARK: - Chess Mode Analysis Models

struct ChessModeAnalysis: Codable {
    var scenario: String
    var strengths: [String] = []
    var weaknesses: [String] = []
    var opportunities: [String] = []
    var threats: [String] = []
    var recommendations: [String] = []
    var dataPoints: [String] = [] // What data was used
    var createdDate: Date
}
