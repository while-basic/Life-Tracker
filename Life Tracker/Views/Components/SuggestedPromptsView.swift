// Created by Celaya Solutions 2025
//
//  SuggestedPromptsView.swift
//  Life Tracker
//

import SwiftUI

struct SuggestedPromptsView: View {
    let mode: AIMode
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(mode.color)

                Text("Try asking...")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TipsManager.shared.getQuickStartPrompts(mode: mode).prefix(3), id: \.self) { prompt in
                        SuggestedPromptBubble(prompt: prompt, color: mode.color) {
                            onSelect(prompt)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(Color(.systemGray6).opacity(0.5))
    }
}

struct SuggestedPromptBubble: View {
    let prompt: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "wand.and.stars")
                    .font(.caption)

                Text(prompt)
                    .font(.subheadline)
                    .lineLimit(2)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(color.opacity(0.15))
            .foregroundColor(.primary)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .frame(maxWidth: 250)
    }
}

// Contextual suggestions based on time and data
struct ContextualSuggestionsView: View {
    let mode: AIMode
    let messageCount: Int
    let hasHealthData: Bool
    let onSelect: (String) -> Void

    private var timeOfDay: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Morning"
        case 12..<17: return "Afternoon"
        case 17..<21: return "Evening"
        default: return "Late Night"
        }
    }

    private var contextualPrompts: [String] {
        var prompts: [String] = []

        // Time-based
        switch timeOfDay {
        case "Morning":
            prompts.append("Help me plan my day")
            prompts.append("What should I prioritize today?")
        case "Afternoon":
            prompts.append("Review my morning progress")
            prompts.append("Help me stay focused")
        case "Evening":
            prompts.append("Reflect on today")
            prompts.append("Plan for tomorrow")
        default:
            prompts.append("What's on your mind?")
        }

        // Mode-specific
        if mode == .chess {
            prompts.append("Analyze this strategic decision...")
        } else if mode == .acting && messageCount == 0 {
            prompts.append("I want to achieve [goal] by [deadline]")
        }

        // Health-based
        if hasHealthData {
            prompts.append("How does my health data look?")
        }

        return prompts
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.purple)

                Text("Suggested for \(timeOfDay)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding(.horizontal)

            ForEach(contextualPrompts.prefix(2), id: \.self) { prompt in
                Button(action: {
                    onSelect(prompt)
                }) {
                    HStack {
                        Text(prompt)
                            .font(.subheadline)

                        Spacer()

                        Image(systemName: "arrow.right.circle")
                            .foregroundColor(mode.color)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                }
                .foregroundColor(.primary)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

#Preview {
    VStack {
        SuggestedPromptsView(mode: .casualChat) { _ in }

        ContextualSuggestionsView(mode: .chess, messageCount: 0, hasHealthData: true) { _ in }
    }
}
