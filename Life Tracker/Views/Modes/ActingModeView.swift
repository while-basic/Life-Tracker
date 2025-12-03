// Created by Celaya Solutions 2025
//
//  ActingModeView.swift
//  Life Tracker
//

import SwiftUI

struct ActingModeView: View {
    @ObservedObject var viewModel: AICompanionViewModel

    @State private var currentGoal = ""
    @State private var steps: [ActionStep] = []
    @State private var showingAddStep = false
    @State private var newStepText = ""

    struct ActionStep: Identifiable {
        let id = UUID()
        var text: String
        var isCompleted: Bool = false
        var notes: String = ""
        var timestamp: Date = Date()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Goal section
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "target")
                        .foregroundColor(.green)
                        .font(.title3)

                    Text("Current Goal")
                        .font(.headline)

                    Spacer()
                }

                if currentGoal.isEmpty {
                    Button(action: {
                        showingAddStep = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Set a Goal")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                } else {
                    Text(currentGoal)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)

            // Steps list
            ScrollView {
                VStack(spacing: 12) {
                    if steps.isEmpty && !currentGoal.isEmpty {
                        EmptyStateView(
                            icon: "figure.walk",
                            title: "No Steps Yet",
                            message: "Break down your goal into actionable steps."
                        )
                        .padding()

                        Button(action: requestAISteps) {
                            Label("Generate Steps with AI", systemImage: "sparkles")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    } else {
                        // Progress indicator
                        if !steps.isEmpty {
                            ProgressSection(steps: steps)
                        }

                        ForEach(steps.indices, id: \.self) { index in
                            StepCard(
                                step: steps[index],
                                stepNumber: index + 1,
                                onToggle: {
                                    steps[index].isCompleted.toggle()
                                },
                                onDelete: {
                                    steps.remove(at: index)
                                }
                            )
                        }

                        Button(action: {
                            showingAddStep = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Add Step")
                            }
                            .font(.subheadline)
                            .foregroundColor(.green)
                        }
                        .padding()
                    }
                }
                .padding()
            }

            // Coach button
            if !currentGoal.isEmpty {
                Button(action: requestCoaching) {
                    Label("Get Coaching", systemImage: "person.fill.checkmark")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding()
                .background(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: -1)
            }
        }
        .sheet(isPresented: $showingAddStep) {
            AddGoalOrStepView(
                isGoal: currentGoal.isEmpty,
                onSave: { text in
                    if currentGoal.isEmpty {
                        currentGoal = text
                    } else {
                        let step = ActionStep(text: text)
                        steps.append(step)
                    }
                    showingAddStep = false
                }
            )
        }
    }

    private func requestAISteps() {
        let prompt = "I want to achieve this goal: \(currentGoal)\n\nBreak this down into clear, actionable steps I can follow."

        viewModel.sendMessage(prompt) { response in
            // Parse response into steps (simplified)
            let lines = response.components(separatedBy: "\n")
                .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

            for line in lines {
                let cleaned = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "^[0-9]+\\.|^-|^\\*", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if !cleaned.isEmpty && cleaned.count > 10 {
                    steps.append(ActionStep(text: cleaned))
                }
            }
        }
    }

    private func requestCoaching() {
        let completedCount = steps.filter { $0.isCompleted }.count
        let totalCount = steps.count

        let prompt = """
        I'm working on: \(currentGoal)

        Progress: \(completedCount)/\(totalCount) steps completed

        Current steps:
        \(steps.enumerated().map { "\($0.offset + 1). [\($0.element.isCompleted ? "✓" : " ")] \($0.element.text)" }.joined(separator: "\n"))

        Please coach me on my next actions and provide encouragement.
        """

        viewModel.sendMessage(prompt) { _ in
            // Coaching received
        }
    }
}

struct ProgressSection: View {
    let steps: [ActingModeView.ActionStep]

    var progress: Double {
        let completed = steps.filter { $0.isCompleted }.count
        return Double(completed) / Double(steps.count)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Progress")
                    .font(.headline)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.headline)
                    .foregroundColor(.green)
            }

            ProgressBarView(value: progress, color: .green)
                .frame(height: 12)

            Text("\(steps.filter { $0.isCompleted }.count) of \(steps.count) steps completed")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
}

struct StepCard: View {
    let step: ActingModeView.ActionStep
    let stepNumber: Int
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Step number
            ZStack {
                Circle()
                    .fill(step.isCompleted ? Color.green : Color(.systemGray5))
                    .frame(width: 32, height: 32)

                if step.isCompleted {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.caption)
                } else {
                    Text("\(stepNumber)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(step.text)
                    .font(.body)
                    .strikethrough(step.isCompleted)
                    .foregroundColor(step.isCompleted ? .secondary : .primary)

                Text(step.timestamp.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onToggle) {
                Image(systemName: step.isCompleted ? "arrow.uturn.backward.circle" : "checkmark.circle")
                    .foregroundColor(step.isCompleted ? .orange : .green)
                    .font(.title3)
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

struct AddGoalOrStepView: View {
    let isGoal: Bool
    let onSave: (String) -> Void

    @State private var text = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: isGoal ? "target" : "figure.walk")
                    .font(.system(size: 50))
                    .foregroundColor(.green)

                Text(isGoal ? "What's your goal?" : "What's the next step?")
                    .font(.headline)

                TextField(isGoal ? "Enter your goal..." : "Enter the step...", text: $text, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
                    .padding(.horizontal)

                Button(action: {
                    onSave(text)
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.green)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()
            }
            .padding()
            .navigationTitle(isGoal ? "Set Goal" : "Add Step")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ActingModeView(viewModel: AICompanionViewModel())
}
