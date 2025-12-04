// Created by Celaya Solutions 2025
//
//  TipsManager.swift
//  Life Tracker
//

import Foundation
import SwiftUI

struct Tip: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let message: String
    let color: Color
}

class TipsManager {
    static let shared = TipsManager()

    private init() {}

    func getTipsForMode(_ mode: AIMode) -> [Tip] {
        switch mode {
        case .casualChat:
            return [
                Tip(icon: "lightbulb.fill", title: "Natural Conversation", message: "Ask questions just like you would with a friend. The AI adapts to your style.", color: .blue),
                Tip(icon: "heart.fill", title: "Health Context", message: "Your health data is shared with responses for personalized insights.", color: .red),
                Tip(icon: "text.book.closed", title: "Use Prompts", message: "Tap the book icon to access your saved prompts for quick starts.", color: .purple)
            ]

        case .planning:
            return [
                Tip(icon: "plus.circle", title: "Add Multiple Ideas", message: "Brainstorm freely - add all your ideas before asking for AI analysis.", color: .orange),
                Tip(icon: "sparkles", title: "AI Organization", message: "Once you have 3+ ideas, tap 'Analyze with AI' to get them organized and prioritized.", color: .orange),
                Tip(icon: "tag.fill", title: "Use Categories", message: "Categorize ideas as Short/Long term or Business/Personal for better organization.", color: .orange)
            ]

        case .acting:
            return [
                Tip(icon: "target", title: "Clear Goals", message: "Start with a specific, measurable goal for best results.", color: .green),
                Tip(icon: "sparkles", title: "AI Steps", message: "Let AI break down your goal into actionable steps automatically.", color: .green),
                Tip(icon: "checkmark.circle", title: "Track Progress", message: "Check off steps as you complete them. I'll celebrate your wins!", color: .green)
            ]

        case .review:
            return [
                Tip(icon: "chart.line.uptrend.xyaxis", title: "Weekly Reviews", message: "Review your patterns weekly for the best insights.", color: .purple),
                Tip(icon: "brain.head.profile", title: "Mood Patterns", message: "Look for correlations between your mood and health metrics.", color: .purple),
                Tip(icon: "sparkles", title: "Deep Analysis", message: "Tap 'Request Detailed Analysis' for AI-powered insights.", color: .purple)
            ]

        case .chess:
            return [
                Tip(icon: "crown.fill", title: "Strategic Thinking", message: "Use this mode for important decisions that require deep analysis.", color: .yellow),
                Tip(icon: "brain.head.profile", title: "All Data Used", message: "I analyze your health, patterns, sentiment, and more for complete insights.", color: .yellow),
                Tip(icon: "list.bullet", title: "SWOT Analysis", message: "Every analysis includes Strengths, Weaknesses, Opportunities, and Threats.", color: .yellow),
                Tip(icon: "clock.fill", title: "Best Timing", message: "Use Chess Mode when you're well-rested and low-stress for optimal decision-making.", color: .yellow)
            ]

        case .confidence:
            return [
                Tip(icon: "lock.shield", title: "Total Privacy", message: "Nothing from this conversation will be saved or analyzed.", color: .gray),
                Tip(icon: "trash.fill", title: "Auto-Delete", message: "When you switch modes or close the app, this conversation disappears.", color: .gray),
                Tip(icon: "eye.slash.fill", title: "No Analytics", message: "Your sentiment, words, and patterns won't be tracked here.", color: .gray)
            ]
        }
    }

    func getContextualTips(mode: AIMode, messageCount: Int, hasHealthData: Bool, timeOfDay: String) -> [Tip] {
        var tips: [Tip] = []

        // First conversation tips
        if messageCount == 0 {
            tips.append(Tip(
                icon: "hand.wave.fill",
                title: "First time in \(mode.rawValue)?",
                message: mode.description,
                color: mode.color
            ))
        }

        // Health data tips
        if !hasHealthData && mode != .confidence {
            tips.append(Tip(
                icon: "heart.fill",
                title: "Enable Health Data",
                message: "Connect HealthKit for insights based on your physiological state.",
                color: .red
            ))
        }

        // Time-based tips
        if mode == .chess && (timeOfDay == "Late Night" || timeOfDay == "Early Morning") {
            tips.append(Tip(
                icon: "moon.fill",
                title: "Decision Fatigue",
                message: "Big decisions are best made mid-morning when you're alert and rested.",
                color: .yellow
            ))
        }

        // Mode-specific contextual tips
        if mode == .planning && messageCount > 5 {
            tips.append(Tip(
                icon: "arrow.right.circle.fill",
                title: "Ready to Act?",
                message: "Switch to Acting Mode to start executing your plan.",
                color: .green
            ))
        }

        if mode == .acting && messageCount > 10 {
            tips.append(Tip(
                icon: "chart.line.uptrend.xyaxis",
                title: "Track Progress",
                message: "Switch to Review Mode to analyze your execution patterns.",
                color: .purple
            ))
        }

        return tips
    }

    func getQuickStartPrompts(mode: AIMode) -> [String] {
        switch mode {
        case .casualChat:
            return [
                "What's the best way to start my day?",
                "Help me think through this idea...",
                "I need advice on...",
                "Can you explain..."
            ]

        case .planning:
            return [
                "I want to plan a project for...",
                "Help me brainstorm ideas for...",
                "I need to organize my thoughts about...",
                "Let's plan the next quarter..."
            ]

        case .acting:
            return [
                "I want to achieve...",
                "Help me execute my plan to...",
                "Break down this goal: ...",
                "I need to get started on..."
            ]

        case .review:
            return [
                "What patterns do you see in my...",
                "Review my progress on...",
                "Analyze my decision-making about...",
                "How have I improved in..."
            ]

        case .chess:
            return [
                "Should I [decision] now or wait?",
                "Analyze this business opportunity...",
                "Strategic advice on...",
                "What's the best move for..."
            ]

        case .confidence:
            return [
                "I need private advice about...",
                "Confidentially, I'm concerned about...",
                "Without saving this, help me with...",
                "Private discussion: ..."
            ]
        }
    }
}
