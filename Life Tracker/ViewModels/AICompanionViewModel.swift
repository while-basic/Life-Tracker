// Created by Celaya Solutions 2025
//
//  AICompanionViewModel.swift
//  Life Tracker
//

import Foundation
import SwiftUI
import Combine

class AICompanionViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var currentMode: AIMode = .casualChat
    @Published var currentConversation: Conversation?
    @Published var conversations: [Conversation] = []
    @Published var promptLibrary = PromptLibrary()
    @Published var psychoanalysisData = PsychoanalysisData()
    @Published var userAnalytics = UserAnalytics()
    @Published var isProcessing = false

    // HealthKit integration
    private let healthKitManager = HealthKitManager.shared

    // MARK: - Init

    init() {
        loadData()
        setupBuiltInPrompts()
    }

    // MARK: - Mode Management

    func switchMode(to mode: AIMode) {
        // End current conversation if switching modes
        if let current = currentConversation, current.mode != mode {
            endConversation()
        }

        currentMode = mode
        startNewConversation()
    }

    // MARK: - Conversation Management

    func startNewConversation() {
        let conversation = Conversation(
            mode: currentMode,
            messages: [],
            startDate: Date()
        )

        currentConversation = conversation

        // Add system message based on mode
        let systemMessage = getSystemMessage(for: currentMode)
        addMessage(role: .system, content: systemMessage)
    }

    func endConversation() {
        guard var conversation = currentConversation else { return }

        conversation.endDate = Date()

        // Generate summary for non-confidence mode
        if currentMode != .confidence {
            conversation.summary = generateConversationSummary(conversation)
            conversations.append(conversation)
            userAnalytics.recordConversation(conversation)
            saveData()
        }

        currentConversation = nil
    }

    func addMessage(role: ConversationMessage.MessageRole, content: String) {
        guard var conversation = currentConversation else { return }

        let healthSnapshot = healthKitManager.getCurrentSnapshot()
        let sentiment = role == .user ? analyzeSentiment(content) : nil

        let message = ConversationMessage(
            role: role,
            content: content,
            timestamp: Date(),
            mode: currentMode,
            sentimentScore: sentiment,
            healthDataSnapshot: healthSnapshot
        )

        conversation.messages.append(message)
        currentConversation = conversation

        // Update psychoanalysis data (skip in Confidence Mode)
        if currentMode != .confidence && role == .user {
            psychoanalysisData.addMessage(message, healthSnapshot: healthSnapshot)

            // Create mood correlation
            if let sentiment = sentiment {
                let correlation = PsychoanalysisData.MoodCorrelation(
                    date: Date(),
                    mood: getMoodFromSentiment(sentiment),
                    sentiment: sentiment,
                    heartRate: healthSnapshot.heartRate,
                    steps: healthSnapshot.steps,
                    sleepHours: healthSnapshot.sleepHours
                )
                psychoanalysisData.moodCorrelations.append(correlation)
            }
        }
    }

    func sendMessage(_ content: String, completion: @escaping (String) -> Void) {
        addMessage(role: .user, content: content)

        isProcessing = true

        // Simulate AI response (in production, this would call Apple Intelligence API)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }

            let response = self.generateAIResponse(for: content)
            self.addMessage(role: .assistant, content: response)

            self.isProcessing = false
            completion(response)
        }
    }

    // MARK: - AI Response Generation

    private func generateAIResponse(for userMessage: String) -> String {
        // This is a placeholder. In production, integrate with Apple Intelligence API
        // For now, return mode-specific responses

        let healthSnapshot = healthKitManager.getCurrentSnapshot()

        switch currentMode {
        case .casualChat:
            return generateCasualResponse(userMessage, healthSnapshot: healthSnapshot)

        case .planning:
            return generatePlanningResponse(userMessage, healthSnapshot: healthSnapshot)

        case .acting:
            return generateActingResponse(userMessage, healthSnapshot: healthSnapshot)

        case .review:
            return generateReviewResponse(userMessage, healthSnapshot: healthSnapshot)

        case .chess:
            return generateChessResponse(userMessage, healthSnapshot: healthSnapshot)

        case .confidence:
            return generateConfidenceResponse(userMessage)
        }
    }

    private func generateCasualResponse(_ message: String, healthSnapshot: HealthDataSnapshot) -> String {
        return "I'm here to chat! I noticed your heart rate is around \(Int(healthSnapshot.heartRate ?? 0)) bpm. How can I help you today?"
    }

    private func generatePlanningResponse(_ message: String, healthSnapshot: HealthDataSnapshot) -> String {
        return "Let's brainstorm together! Based on your activity patterns, I see you're most active during the day. What are you planning?"
    }

    private func generateActingResponse(_ message: String, healthSnapshot: HealthDataSnapshot) -> String {
        return "Let's break this down into actionable steps:\n\n1. First, clarify your goal\n2. Identify resources needed\n3. Create a timeline\n4. Execute with focus\n\nWhat's your first step?"
    }

    private func generateReviewResponse(_ message: String, healthSnapshot: HealthDataSnapshot) -> String {
        let avgSentiment = psychoanalysisData.getAverageSentiment()
        let moodDescription = getMoodFromSentiment(avgSentiment)

        return "Let's review your patterns. Your average sentiment has been \(moodDescription). You've had \(userAnalytics.totalConversations) conversations across different modes. What would you like to explore?"
    }

    private func generateChessResponse(_ message: String, healthSnapshot: HealthDataSnapshot) -> String {
        return "Strategic Analysis Mode Active.\n\nAnalyzing scenario using all available data:\n- Your physiological state: \(getPhysiologicalState(healthSnapshot))\n- Communication patterns: \(psychoanalysisData.communicationPatterns.formalityScore > 0.5 ? "Formal" : "Casual")\n- Recent sentiment trend: \(getSentimentTrend())\n\nProvide the scenario you want me to analyze strategically."
    }

    private func generateConfidenceResponse(_ message: String) -> String {
        return "Privacy mode active. I'm here to help, and nothing from this conversation will be stored or remembered. What would you like to discuss?"
    }

    // MARK: - Chess Mode Analysis

    func performChessAnalysis(scenario: String) -> ChessModeAnalysis {
        let healthSnapshot = healthKitManager.getCurrentSnapshot()
        let avgSentiment = psychoanalysisData.getAverageSentiment()

        var analysis = ChessModeAnalysis(
            scenario: scenario,
            createdDate: Date()
        )

        // Collect data points used
        analysis.dataPoints = [
            "Heart Rate: \(Int(healthSnapshot.heartRate ?? 0)) bpm",
            "Steps Today: \(healthSnapshot.steps ?? 0)",
            "Sleep: \(String(format: "%.1f", healthSnapshot.sleepHours ?? 0)) hours",
            "Average Sentiment: \(String(format: "%.2f", avgSentiment))",
            "Stress Level: \(String(format: "%.2f", healthSnapshot.stressLevel ?? 0))",
            "Total Conversations: \(userAnalytics.totalConversations)"
        ]

        // SWOT Analysis (simplified - in production, use AI)
        analysis.strengths = [
            "Strong data foundation for decision-making",
            "Self-awareness through tracking",
            "Consistent engagement with personal development"
        ]

        analysis.weaknesses = [
            "May rely too heavily on data",
            "Need to balance analysis with action"
        ]

        analysis.opportunities = [
            "Leverage insights for strategic planning",
            "Optimize timing based on physiological state",
            "Use patterns to predict optimal performance windows"
        ]

        analysis.threats = [
            "Information overload",
            "Analysis paralysis",
            "Missing intuitive insights by over-analyzing"
        ]

        analysis.recommendations = [
            "Act when stress levels are low and sentiment is positive",
            "Use morning hours (based on activity patterns) for critical decisions",
            "Balance data-driven insights with gut feelings"
        ]

        return analysis
    }

    // MARK: - Sentiment Analysis

    private func analyzeSentiment(_ text: String) -> Double {
        // Simple sentiment analysis (in production, use NLP/Apple Intelligence)
        let positiveWords = ["great", "awesome", "good", "excellent", "happy", "wonderful", "fantastic", "love", "amazing", "perfect"]
        let negativeWords = ["bad", "terrible", "awful", "hate", "horrible", "worst", "sad", "angry", "frustrated", "disappointed"]

        let lowercased = text.lowercased()
        var score = 0.0

        for word in positiveWords {
            if lowercased.contains(word) {
                score += 0.2
            }
        }

        for word in negativeWords {
            if lowercased.contains(word) {
                score -= 0.2
            }
        }

        return max(-1.0, min(1.0, score))
    }

    private func getMoodFromSentiment(_ sentiment: Double) -> String {
        switch sentiment {
        case 0.5...1.0: return "Very Positive"
        case 0.2..<0.5: return "Positive"
        case -0.2..<0.2: return "Neutral"
        case -0.5..<(-0.2): return "Negative"
        default: return "Very Negative"
        }
    }

    // MARK: - Helper Methods

    private func getSystemMessage(for mode: AIMode) -> String {
        switch mode {
        case .casualChat:
            return "Welcome to Casual Chat mode. I'm here for natural conversation and assistance."

        case .planning:
            return "Welcome to Planning mode. Let's brainstorm and prepare together."

        case .acting:
            return "Welcome to Acting mode. I'll guide you step-by-step through execution."

        case .review:
            return "Welcome to Review mode. Let's analyze your patterns and decisions."

        case .chess:
            return "Welcome to Chess Mode. Strategic analysis using all available data is active."

        case .confidence:
            return "Welcome to Confidence mode. Privacy enabled - nothing will be remembered."
        }
    }

    private func generateConversationSummary(_ conversation: Conversation) -> String {
        let messageCount = conversation.messages.count
        let userMessages = conversation.messages.filter { $0.role == .user }
        let avgSentiment = userMessages.compactMap { $0.sentimentScore }.reduce(0, +) / Double(max(userMessages.count, 1))

        return "Mode: \(conversation.mode.rawValue) | Messages: \(messageCount) | Sentiment: \(getMoodFromSentiment(avgSentiment))"
    }

    private func getPhysiologicalState(_ snapshot: HealthDataSnapshot) -> String {
        guard let hr = snapshot.heartRate else { return "Unknown" }

        switch hr {
        case 0..<60: return "Relaxed"
        case 60..<80: return "Normal"
        case 80..<100: return "Elevated"
        default: return "High"
        }
    }

    private func getSentimentTrend() -> String {
        let recent = psychoanalysisData.getSentimentTrend(days: 7)
        guard !recent.isEmpty else { return "Neutral" }

        let avg = recent.reduce(0) { $0 + $1.sentiment } / Double(recent.count)
        return getMoodFromSentiment(avg)
    }

    // MARK: - Prompt Library

    private func setupBuiltInPrompts() {
        let builtInPrompts: [Prompt] = [
            Prompt(
                title: "Daily Planning",
                content: "Help me plan my day considering my energy levels and priorities.",
                category: .productivity,
                mode: .planning,
                isBuiltIn: true,
                createdDate: Date()
            ),
            Prompt(
                title: "Strategic Decision",
                content: "Analyze this decision using all available data about my patterns and state.",
                category: .business,
                mode: .chess,
                isBuiltIn: true,
                createdDate: Date()
            ),
            Prompt(
                title: "Wellness Check",
                content: "Review my wellness patterns and suggest improvements.",
                category: .wellness,
                mode: .review,
                isBuiltIn: true,
                createdDate: Date()
            ),
            Prompt(
                title: "Action Steps",
                content: "Break down this goal into specific, actionable steps.",
                category: .productivity,
                mode: .acting,
                isBuiltIn: true,
                createdDate: Date()
            )
        ]

        for prompt in builtInPrompts {
            if !promptLibrary.prompts.contains(where: { $0.title == prompt.title }) {
                promptLibrary.addPrompt(prompt)
            }
        }
    }

    // MARK: - Data Persistence

    func loadData() {
        // Load conversations
        if let data = UserDefaults.standard.data(forKey: "aiConversations") {
            if let decoded = try? JSONDecoder().decode([Conversation].self, from: data) {
                conversations = decoded
            }
        }

        // Load prompt library
        if let data = UserDefaults.standard.data(forKey: "promptLibrary") {
            if let decoded = try? JSONDecoder().decode(PromptLibrary.self, from: data) {
                promptLibrary = decoded
            }
        }

        // Load psychoanalysis data
        if let data = UserDefaults.standard.data(forKey: "psychoanalysisData") {
            if let decoded = try? JSONDecoder().decode(PsychoanalysisData.self, from: data) {
                psychoanalysisData = decoded
            }
        }

        // Load analytics
        if let data = UserDefaults.standard.data(forKey: "userAnalytics") {
            if let decoded = try? JSONDecoder().decode(UserAnalytics.self, from: data) {
                userAnalytics = decoded
            }
        }
    }

    func saveData() {
        // Save conversations
        if let encoded = try? JSONEncoder().encode(conversations) {
            UserDefaults.standard.set(encoded, forKey: "aiConversations")
        }

        // Save prompt library
        if let encoded = try? JSONEncoder().encode(promptLibrary) {
            UserDefaults.standard.set(encoded, forKey: "promptLibrary")
        }

        // Save psychoanalysis data
        if let encoded = try? JSONEncoder().encode(psychoanalysisData) {
            UserDefaults.standard.set(encoded, forKey: "psychoanalysisData")
        }

        // Save analytics
        if let encoded = try? JSONEncoder().encode(userAnalytics) {
            UserDefaults.standard.set(encoded, forKey: "userAnalytics")
        }
    }
}
