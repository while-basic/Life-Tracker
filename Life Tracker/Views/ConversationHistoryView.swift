// Created by Celaya Solutions 2025
//
//  ConversationHistoryView.swift
//  Life Tracker
//

import SwiftUI

struct ConversationHistoryView: View {
    @ObservedObject var viewModel: AICompanionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var selectedMode: AIMode?
    @State private var selectedConversation: Conversation?
    @State private var showingConversationDetail = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search
                SearchBar(text: $searchText)
                    .padding()

                // Mode filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(
                            title: "All Modes",
                            isSelected: selectedMode == nil
                        ) {
                            selectedMode = nil
                        }

                        ForEach(AIMode.allCases, id: \.self) { mode in
                            FilterChip(
                                title: mode.rawValue,
                                isSelected: selectedMode == mode,
                                color: mode.color
                            ) {
                                selectedMode = mode
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }

                // Conversations list
                if filteredConversations.isEmpty {
                    EmptyStateView(
                        icon: "bubble.left.and.bubble.right",
                        title: "No Conversations Yet",
                        message: searchText.isEmpty
                            ? "Your conversation history will appear here. Start chatting to build your history!"
                            : "No conversations match your search."
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredConversations) { conversation in
                                ConversationHistoryCard(
                                    conversation: conversation,
                                    onTap: {
                                        selectedConversation = conversation
                                        showingConversationDetail = true
                                    },
                                    onDelete: {
                                        deleteConversation(conversation)
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Conversation History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedConversation) { conversation in
                ConversationDetailView(conversation: conversation)
            }
        }
    }

    private var filteredConversations: [Conversation] {
        var conversations = viewModel.conversations

        // Filter by mode
        if let mode = selectedMode {
            conversations = conversations.filter { $0.mode == mode }
        }

        // Filter by search
        if !searchText.isEmpty {
            conversations = conversations.filter { conversation in
                // Search in title
                if let title = conversation.title, title.localizedCaseInsensitiveContains(searchText) {
                    return true
                }

                // Search in summary
                if let summary = conversation.summary, summary.localizedCaseInsensitiveContains(searchText) {
                    return true
                }

                // Search in messages
                return conversation.messages.contains { message in
                    message.content.localizedCaseInsensitiveContains(searchText)
                }
            }
        }

        return conversations.sorted { $0.startDate > $1.startDate }
    }

    private func deleteConversation(_ conversation: Conversation) {
        viewModel.conversations.removeAll { $0.id == conversation.id }
        viewModel.saveData()
    }
}

struct ConversationHistoryCard: View {
    let conversation: Conversation
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: conversation.mode.icon)
                        .foregroundColor(conversation.mode.color)

                    Text(conversation.mode.rawValue)
                        .font(.caption)
                        .foregroundColor(conversation.mode.color)

                    Spacer()

                    Text(conversation.startDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Title or first message
                Text(conversation.title ?? conversation.messages.first(where: { $0.role == .user })?.content ?? "Untitled Conversation")
                    .font(.headline)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Summary
                if let summary = conversation.summary {
                    Text(summary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                // Stats
                HStack {
                    Label("\(conversation.messages.count)", systemImage: "message.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    if let duration = conversation.endDate?.timeIntervalSince(conversation.startDate) {
                        let minutes = Int(duration / 60)
                        Text("\(minutes) min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ConversationDetailView: View {
    let conversation: Conversation
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Metadata
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: conversation.mode.icon)
                                .foregroundColor(conversation.mode.color)
                                .font(.title2)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(conversation.mode.rawValue)
                                    .font(.headline)

                                Text(conversation.startDate.formatted(date: .long, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }

                        if let summary = conversation.summary {
                            Text(summary)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                    }
                    .padding()

                    Divider()

                    // Messages
                    VStack(spacing: 12) {
                        ForEach(conversation.messages.filter { $0.role != .system }) { message in
                            MessageBubbleReadOnly(message: message)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Conversation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: exportConversation) {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }

                        Button(action: shareConversation) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func exportConversation() {
        // Export to text format
        var text = """
        Conversation: \(conversation.mode.rawValue)
        Date: \(conversation.startDate.formatted(date: .long, time: .shortened))

        """

        for message in conversation.messages.filter({ $0.role != .system }) {
            text += "\n\(message.role == .user ? "You" : "AI"): \(message.content)\n"
        }

        UIPasteboard.general.string = text
    }

    private func shareConversation() {
        // Future: implement share sheet
    }
}

struct MessageBubbleReadOnly: View {
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

                HStack(spacing: 8) {
                    Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    if let sentiment = message.sentimentScore {
                        let emoji = sentiment > 0.3 ? "😊" : sentiment < -0.3 ? "😟" : "😐"
                        Text(emoji)
                            .font(.caption2)
                    }
                }
            }

            if message.role == .assistant {
                Spacer()
            }
        }
    }
}

#Preview {
    ConversationHistoryView(viewModel: AICompanionViewModel())
}
