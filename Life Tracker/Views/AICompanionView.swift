// Created by Celaya Solutions 2025
//
//  AICompanionView.swift
//  Life Tracker
//

import SwiftUI

struct AICompanionView: View {
    @StateObject private var viewModel = AICompanionViewModel()
    @State private var showModeSelector = false
    @State private var showPromptLibrary = false
    @State private var showAnalytics = false
    @State private var healthKitAuthorized = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Mode indicator bar
                HStack {
                    Image(systemName: viewModel.currentMode.icon)
                        .foregroundColor(viewModel.currentMode.color)
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.currentMode.rawValue)
                            .font(.headline)

                        Text(viewModel.currentMode.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Button(action: {
                        showModeSelector = true
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(.blue)
                            .font(.title3)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)

                // Mode-specific view
                Group {
                    switch viewModel.currentMode {
                    case .casualChat:
                        ConversationView(viewModel: viewModel)

                    case .planning:
                        PlanningModeView(viewModel: viewModel)

                    case .acting:
                        ActingModeView(viewModel: viewModel)

                    case .review:
                        ReviewModeView(viewModel: viewModel)

                    case .chess:
                        ChessModeView(viewModel: viewModel)

                    case .confidence:
                        ConversationView(viewModel: viewModel, isConfidenceMode: true)
                    }
                }
            }
            .navigationTitle("AI Companion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            showPromptLibrary = true
                        }) {
                            Image(systemName: "text.book.closed")
                        }

                        Button(action: {
                            showAnalytics = true
                        }) {
                            Image(systemName: "chart.bar")
                        }
                    }
                }
            }
            .sheet(isPresented: $showModeSelector) {
                ModeSelectorView(viewModel: viewModel, isPresented: $showModeSelector)
            }
            .sheet(isPresented: $showPromptLibrary) {
                PromptLibraryView(viewModel: viewModel)
            }
            .sheet(isPresented: $showAnalytics) {
                AnalyticsView(viewModel: viewModel)
            }
            .onAppear {
                requestHealthKitPermission()
                viewModel.startNewConversation()
            }
        }
    }

    private func requestHealthKitPermission() {
        HealthKitManager.shared.requestAuthorization { success, error in
            healthKitAuthorized = success

            if success {
                HealthKitManager.shared.fetchAllHealthData { _ in
                    // Data fetched
                }
            }
        }
    }
}

// MARK: - Mode Selector View

struct ModeSelectorView: View {
    @ObservedObject var viewModel: AICompanionViewModel
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(AIMode.allCases, id: \.self) { mode in
                        ModeCard(mode: mode, isSelected: viewModel.currentMode == mode) {
                            viewModel.switchMode(to: mode)
                            isPresented = false
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Select Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct ModeCard: View {
    let mode: AIMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: mode.icon)
                    .font(.title2)
                    .foregroundColor(mode.color)
                    .frame(width: 50, height: 50)
                    .background(mode.color.opacity(0.1))
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(mode.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(mode.color)
                        .font(.title3)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? mode.color : Color(.systemGray5), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Conversation View (for Casual Chat and Confidence Mode)

struct ConversationView: View {
    @ObservedObject var viewModel: AICompanionViewModel
    var isConfidenceMode: Bool = false

    @State private var messageText = ""
    @State private var showingHealthData = false

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollView {
                ScrollViewReader { proxy in
                    VStack(spacing: 12) {
                        if let conversation = viewModel.currentConversation {
                            ForEach(conversation.messages.filter { $0.role != .system }) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }

                            if viewModel.isProcessing {
                                TypingIndicator()
                            }
                        }
                    }
                    .padding()
                    .onChange(of: viewModel.currentConversation?.messages.count) { _ in
                        if let lastMessage = viewModel.currentConversation?.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Input bar
            HStack(spacing: 12) {
                Button(action: {
                    showingHealthData.toggle()
                }) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                }

                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: -1)

            if showingHealthData {
                HealthDataBar()
                    .transition(.move(edge: .bottom))
            }
        }
    }

    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        viewModel.sendMessage(text) { _ in
            // Response received
        }

        messageText = ""
    }
}

struct MessageBubble: View {
    let message: ConversationMessage

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(message.role == .user ? Color.blue : Color(.systemGray5))
                    .foregroundColor(message.role == .user ? .white : .primary)
                    .cornerRadius(16)

                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if message.role == .assistant {
                Spacer()
            }
        }
    }
}

struct TypingIndicator: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 8)
                    .opacity(animating ? 0.3 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .padding(12)
        .background(Color(.systemGray5))
        .cornerRadius(16)
        .onAppear {
            animating = true
        }
    }
}

struct HealthDataBar: View {
    @ObservedObject private var healthKitManager = HealthKitManager.shared

    var body: some View {
        VStack(spacing: 8) {
            Text("Current Health Data")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                if let hr = healthKitManager.healthData.heartRateData.last?.value {
                    HealthMetric(icon: "heart.fill", value: "\(Int(hr))", unit: "bpm", color: .red)
                }

                if let steps = healthKitManager.healthData.stepsData.last?.value {
                    HealthMetric(icon: "figure.walk", value: "\(Int(steps))", unit: "steps", color: .green)
                }

                if let sleep = healthKitManager.healthData.sleepData.last?.value {
                    HealthMetric(icon: "moon.fill", value: String(format: "%.1f", sleep), unit: "hrs", color: .purple)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

struct HealthMetric: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)

            Text(value)
                .font(.headline)

            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    AICompanionView()
}
