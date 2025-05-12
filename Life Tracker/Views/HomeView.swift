// Created by Celaya Solutions 2025
//
//  HomeView.swift
//  Life Tracker

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var showingStorybook = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // AI-Powered Snapshot
                    if !viewModel.insights.isEmpty {
                        InsightCardView(insight: viewModel.insights[0])
                    } else {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.blue)
                                Text("Insights")
                                    .font(.headline)
                            }
                            
                            VStack {
                                Text("Tap the refresh button to generate AI insights based on your data.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 8)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    
                    // Upcoming Events
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            Text("Upcoming Events")
                                .font(.headline)
                        }
                        
                        if viewModel.upcomingEvents.isEmpty {
                            VStack {
                                Text("No upcoming events")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 8)
                            }
                        } else {
                            VStack(spacing: 12) {
                                ForEach(viewModel.upcomingEvents.prefix(3)) { event in
                                    HStack {
                                        Circle()
                                            .fill(eventColor(for: event.category))
                                            .frame(width: 10, height: 10)
                                        
                                        Text(event.title)
                                            .font(.subheadline)
                                        
                                        Spacer()
                                        
                                        Text(event.startTime.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    if event.id != viewModel.upcomingEvents.prefix(3).last?.id {
                                        Divider()
                                    }
                                }
                                
                                if viewModel.upcomingEvents.count > 3 {
                                    NavigationLink(destination: CalendarView()) {
                                        Text("View all \(viewModel.upcomingEvents.count) events")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.top, 4)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Upcoming Expenses
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "dollarsign.circle")
                                .foregroundColor(.blue)
                            Text("Upcoming Expenses")
                                .font(.headline)
                        }
                        
                        if viewModel.upcomingExpenses.isEmpty {
                            VStack {
                                Text("No upcoming expenses")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 8)
                            }
                        } else {
                            VStack(spacing: 12) {
                                ForEach(viewModel.upcomingExpenses.prefix(3)) { expense in
                                    HStack {
                                        Circle()
                                            .fill(categoryColor(for: expense.category))
                                            .frame(width: 10, height: 10)
                                        
                                        Text(expense.name)
                                            .font(.subheadline)
                                        
                                        Spacer()
                                        
                                        Text("$\(String(format: "%.2f", expense.amount))")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    if expense.id != viewModel.upcomingExpenses.prefix(3).last?.id {
                                        Divider()
                                    }
                                }
                                
                                if viewModel.upcomingExpenses.count > 3 {
                                    NavigationLink(destination: FinancialView()) {
                                        Text("View all \(viewModel.upcomingExpenses.count) expenses")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.top, 4)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Savings Goals
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.blue)
                            Text("Savings Goals")
                                .font(.headline)
                        }
                        
                        if viewModel.savingsGoals.isEmpty {
                            VStack {
                                Text("No savings goals")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 8)
                            }
                        } else {
                            VStack(spacing: 16) {
                                ForEach(viewModel.savingsGoals.prefix(2)) { goal in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(goal.name)
                                                .font(.subheadline)
                                            
                                            Spacer()
                                            
                                            Text("$\(String(format: "%.0f", goal.currentAmount)) / $\(String(format: "%.0f", goal.targetAmount))")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        ProgressBarView(value: goal.progress, color: .green)
                                            .frame(height: 8)
                                        
                                        if let targetDate = goal.targetDate {
                                            Text("Target: \(targetDate.formatted(date: .abbreviated, time: .omitted))")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                
                                if viewModel.savingsGoals.count > 2 {
                                    NavigationLink(destination: FinancialView()) {
                                        Text("View all \(viewModel.savingsGoals.count) goals")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.top, 4)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Welcome or Reflection Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "text.book.closed.fill")
                                .foregroundColor(.blue)
                            Text("Welcome")
                                .font(.headline)
                        }
                        
                        VStack {
                            if viewModel.expenses.isEmpty && viewModel.events.isEmpty && viewModel.savingsGoals.isEmpty {
                                // Show welcome message for new users
                                Text("Welcome to Life Tracker! Add your events, expenses, and goals to start tracking your life. This app will help you organize and visualize your daily activities.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 8)
                            } else if !viewModel.stories.isEmpty {
                                // Show the most recent story if available
                                Text(viewModel.stories[0].content)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 8)
                            } else {
                                // Show a generic message if there's user data but no stories
                                Text("Track your progress and see insights about your life as you add more data.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                .padding()
            }
            .navigationTitle("Life Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            // Navigate to Storybook
                            showingStorybook = true
                        }) {
                            Image(systemName: "book.fill")
                        }
                        
                        Button(action: {
                            // Refresh data or generate new insights
                            viewModel.generateInsights()
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingStorybook) {
                StorybookView(viewModel: viewModel)
            }
        }
    }
    
    // Helper functions for colors
    private func eventColor(for category: Event.EventCategory) -> Color {
        switch category {
        case .birthday, .anniversary:
            return .purple
        case .meeting:
            return .blue
        case .medication, .doctor:
            return .red
        case .gym:
            return .green
        case .studio:
            return .orange
        case .general:
            return .gray
        }
    }
    
    private func categoryColor(for category: Expense.ExpenseCategory) -> Color {
        switch category {
        case .housing:
            return .blue
        case .utilities:
            return .yellow
        case .food:
            return .green
        case .transportation:
            return .orange
        case .entertainment:
            return .purple
        case .healthcare:
            return .red
        case .education:
            return .cyan
        case .personal:
            return .mint
        case .debt:
            return .gray
        case .other:
            return .brown
        }
    }
}

// Add a StorybookView to display the user's stories
struct StorybookView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPeriod: Story.StoryPeriod?
    @State private var selectedStory: Story?
    @State private var showingStoryDetail = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Period filter
                Picker("Filter", selection: $selectedPeriod) {
                    Text("All").tag(nil as Story.StoryPeriod?)
                    ForEach(Story.StoryPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period as Story.StoryPeriod?)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Analytics summary
                HStack(spacing: 20) {
                    analyticCard(
                        title: "Stories",
                        value: "\(filteredStories.count)",
                        icon: "book.closed",
                        color: .blue
                    )
                    
                    analyticCard(
                        title: "Journal Entries",
                        value: "\(viewModel.journalEntries.count)",
                        icon: "pencil",
                        color: .green
                    )
                }
                .padding(.horizontal)
                
                // Stories list
                if filteredStories.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No stories yet")
                            .font(.headline)
                        
                        Text("Create journal entries and generate stories to see them here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            viewModel.generateStory(for: .weekly)
                        }) {
                            Label("Generate Story", systemImage: "wand.and.stars")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredStories) { story in
                            Button(action: {
                                selectedStory = story
                                showingStoryDetail = true
                            }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(story.title)
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        Text(story.generationDate.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text(story.content)
                                        .font(.subheadline)
                                        .lineLimit(2)
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        Spacer()
                                        
                                        Text("Tap to read full story")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Storybook")
            .navigationBarItems(
                leading: Button("Close") {
                    dismiss()
                },
                trailing: Button(action: {
                    let period = selectedPeriod ?? .weekly
                    viewModel.generateStory(for: period)
                }) {
                    Label("New Story", systemImage: "plus")
                }
            )
            .sheet(isPresented: $showingStoryDetail) {
                if let story = selectedStory {
                    storyDetailView(story: story)
                }
            }
        }
    }
    
    private var filteredStories: [Story] {
        if let period = selectedPeriod {
            return viewModel.stories.filter { $0.period == period }
        } else {
            return viewModel.stories
        }
    }
    
    private func storyDetailView(story: Story) -> some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(story.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Generated on \(story.generationDate.formatted(date: .long, time: .shortened))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Period: \(story.period.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text(story.content)
                        .font(.body)
                        .lineSpacing(4)
                }
                .padding()
            }
            .navigationTitle("Story Details")
            .navigationBarItems(trailing: Button("Close") {
                showingStoryDetail = false
            })
        }
    }
    
    private func analyticCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppViewModel())
} 