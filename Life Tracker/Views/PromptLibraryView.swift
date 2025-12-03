// Created by Celaya Solutions 2025
//
//  PromptLibraryView.swift
//  Life Tracker
//

import SwiftUI

struct PromptLibraryView: View {
    @ObservedObject var viewModel: AICompanionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var selectedCategory: Prompt.PromptCategory?
    @State private var selectedMode: AIMode?
    @State private var showingAddPrompt = false
    @State private var showingPromptDetail: Prompt?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $searchText)
                    .padding()

                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(
                            title: "All Categories",
                            isSelected: selectedCategory == nil
                        ) {
                            selectedCategory = nil
                        }

                        ForEach(Prompt.PromptCategory.allCases, id: \.self) { category in
                            FilterChip(
                                title: category.rawValue,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }

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

                // Prompts list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredPrompts) { prompt in
                            PromptCard(prompt: prompt) {
                                showingPromptDetail = prompt
                            } onUse: {
                                usePrompt(prompt)
                            } onDelete: {
                                deletePrompt(prompt)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Prompt Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddPrompt = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPrompt) {
                AddPromptView(viewModel: viewModel)
            }
            .sheet(item: $showingPromptDetail) { prompt in
                PromptDetailView(prompt: prompt, viewModel: viewModel)
            }
        }
    }

    private var filteredPrompts: [Prompt] {
        var prompts = viewModel.promptLibrary.prompts

        if !searchText.isEmpty {
            prompts = viewModel.promptLibrary.searchPrompts(query: searchText)
        }

        if let category = selectedCategory {
            prompts = prompts.filter { $0.category == category }
        }

        if let mode = selectedMode {
            prompts = prompts.filter { $0.mode == mode }
        }

        return prompts.sorted { $0.createdDate > $1.createdDate }
    }

    private func usePrompt(_ prompt: Prompt) {
        viewModel.promptLibrary.usePrompt(prompt.id)
        viewModel.sendMessage(prompt.content) { _ in
            dismiss()
        }
    }

    private func deletePrompt(_ prompt: Prompt) {
        viewModel.promptLibrary.deletePrompt(prompt)
        viewModel.saveData()
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search prompts...", text: $text)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .blue
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color(.systemGray5))
                .cornerRadius(20)
        }
    }
}

struct PromptCard: View {
    let prompt: Prompt
    let onTap: () -> Void
    let onUse: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: prompt.mode.icon)
                    .foregroundColor(prompt.mode.color)

                Text(prompt.title)
                    .font(.headline)

                Spacer()

                if prompt.isBuiltIn {
                    Text("Built-in")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
            }

            // Content preview
            Text(prompt.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            // Footer
            HStack {
                Label(prompt.category.rawValue, systemImage: "tag.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if let lastUsed = prompt.lastUsedDate {
                    Text("Used \(lastUsed.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text("\(prompt.usageCount) uses")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Actions
            HStack(spacing: 12) {
                Button(action: onTap) {
                    Label("View", systemImage: "eye")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }

                Button(action: onUse) {
                    Label("Use", systemImage: "play.fill")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(prompt.mode.color)
                        .cornerRadius(8)
                }

                if !prompt.isBuiltIn {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct AddPromptView: View {
    @ObservedObject var viewModel: AICompanionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var content = ""
    @State private var category: Prompt.PromptCategory = .custom
    @State private var mode: AIMode = .casualChat
    @State private var tags = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)

                    TextField("Content", text: $content, axis: .vertical)
                        .lineLimit(5...10)
                }

                Section("Classification") {
                    Picker("Category", selection: $category) {
                        ForEach(Prompt.PromptCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }

                    Picker("Mode", selection: $mode) {
                        ForEach(AIMode.allCases, id: \.self) { mode in
                            HStack {
                                Image(systemName: mode.icon)
                                Text(mode.rawValue)
                            }
                            .tag(mode)
                        }
                    }
                }

                Section("Tags (optional)") {
                    TextField("Comma-separated tags", text: $tags)
                }

                Section {
                    Button(action: savePrompt) {
                        Text("Save Prompt")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(isValid ? Color.blue : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(!isValid)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Add Prompt")
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

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func savePrompt() {
        let tagArray = tags
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let prompt = Prompt(
            title: title,
            content: content,
            category: category,
            mode: mode,
            isBuiltIn: false,
            createdDate: Date(),
            tags: tagArray
        )

        viewModel.promptLibrary.addPrompt(prompt)
        viewModel.saveData()

        dismiss()
    }
}

struct PromptDetailView: View {
    let prompt: Prompt
    @ObservedObject var viewModel: AICompanionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Mode and category
                    HStack {
                        Label(prompt.mode.rawValue, systemImage: prompt.mode.icon)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(prompt.mode.color)
                            .cornerRadius(20)

                        Label(prompt.category.rawValue, systemImage: "tag.fill")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray)
                            .cornerRadius(20)
                    }

                    // Title
                    Text(prompt.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    // Content
                    Text(prompt.content)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    // Tags
                    if !prompt.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.headline)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(prompt.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }
                    }

                    // Stats
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Statistics")
                            .font(.headline)

                        HStack {
                            VStack(alignment: .leading) {
                                Text("Created")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Text(prompt.createdDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline)
                            }

                            Spacer()

                            VStack(alignment: .trailing) {
                                Text("Usage Count")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Text("\(prompt.usageCount)")
                                    .font(.subheadline)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }

                    // Use button
                    Button(action: {
                        viewModel.promptLibrary.usePrompt(prompt.id)
                        viewModel.sendMessage(prompt.content) { _ in
                            dismiss()
                        }
                    }) {
                        Label("Use This Prompt", systemImage: "play.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(prompt.mode.color)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Prompt Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PromptLibraryView(viewModel: AICompanionViewModel())
}
