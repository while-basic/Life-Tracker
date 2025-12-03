// Created by Celaya Solutions 2025
//
//  PlanningModeView.swift
//  Life Tracker
//

import SwiftUI

struct PlanningModeView: View {
    @ObservedObject var viewModel: AICompanionViewModel

    @State private var brainstormText = ""
    @State private var ideas: [Idea] = []
    @State private var selectedCategory: IdeaCategory = .all

    enum IdeaCategory: String, CaseIterable {
        case all = "All"
        case shortTerm = "Short Term"
        case longTerm = "Long Term"
        case business = "Business"
        case personal = "Personal"
    }

    struct Idea: Identifiable {
        let id = UUID()
        var text: String
        var category: IdeaCategory
        var priority: Int = 1
        var timestamp: Date = Date()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(IdeaCategory.allCases, id: \.self) { category in
                        CategoryChip(
                            title: category.rawValue,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)

            // Ideas list
            ScrollView {
                VStack(spacing: 12) {
                    if filteredIdeas.isEmpty {
                        EmptyStateView(
                            icon: "lightbulb.fill",
                            title: "No Ideas Yet",
                            message: "Start brainstorming! Add your thoughts and I'll help you organize them."
                        )
                        .padding()
                    } else {
                        ForEach(filteredIdeas) { idea in
                            IdeaCard(idea: idea) {
                                // Delete idea
                                ideas.removeAll { $0.id == idea.id }
                            }
                        }
                    }
                }
                .padding()
            }

            // Input section
            VStack(spacing: 12) {
                Text("What are you planning?")
                    .font(.headline)
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    TextField("Add an idea or goal...", text: $brainstormText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: addIdea) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                    .disabled(brainstormText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                Button(action: analyzeWithAI) {
                    Label("Analyze with AI", systemImage: "sparkles")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                .disabled(ideas.isEmpty)
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: -1)
        }
    }

    private var filteredIdeas: [Idea] {
        if selectedCategory == .all {
            return ideas.sorted { $0.timestamp > $1.timestamp }
        } else {
            return ideas.filter { $0.category == selectedCategory }.sorted { $0.timestamp > $1.timestamp }
        }
    }

    private func addIdea() {
        let text = brainstormText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let idea = Idea(text: text, category: selectedCategory == .all ? .personal : selectedCategory)
        ideas.append(idea)

        brainstormText = ""
    }

    private func analyzeWithAI() {
        let ideasText = ideas.map { "- \($0.text) [\($0.category.rawValue)]" }.joined(separator: "\n")
        let prompt = "I'm brainstorming the following ideas:\n\n\(ideasText)\n\nHelp me organize, prioritize, and develop these ideas further."

        viewModel.sendMessage(prompt) { _ in
            // Analysis complete
        }
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.orange : Color(.systemGray5))
                .cornerRadius(20)
        }
    }
}

struct IdeaCard: View {
    let idea: PlanningModeView.Idea
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.orange)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(idea.text)
                    .font(.body)

                HStack {
                    Text(idea.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(idea.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.subheadline)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    PlanningModeView(viewModel: AICompanionViewModel())
}
