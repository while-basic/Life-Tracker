// Created by Celaya Solutions 2025
//
//  ProfileView.swift
//  Life Tracker
//
import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = AppViewModel()
    @State private var selectedTab = 0
    
    private var tabs = ["Overview", "Badges", "Settings"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Profile header
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Chris Celaya")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Life Tracker Pro")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical)
                
                // Tab selector
                HStack(spacing: 0) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Button(action: {
                            selectedTab = index
                        }) {
                            Text(tabs[index])
                                .font(.subheadline)
                                .fontWeight(selectedTab == index ? .semibold : .regular)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(
                                    selectedTab == index ?
                                    Color.blue.opacity(0.1) :
                                    Color.clear
                                )
                                .foregroundColor(selectedTab == index ? .blue : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Content based on selected tab
                ScrollView {
                    VStack(spacing: 16) {
                        switch selectedTab {
                        case 0: // Overview
                            overviewView
                        case 1: // Badges
                            badgesView
                        case 2: // Settings
                            settingsView
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Edit profile
                    }) {
                        Image(systemName: "pencil")
                    }
                }
            }
        }
    }
    
    // MARK: - Tab Views
    
    private var overviewView: some View {
        VStack(spacing: 20) {
            // Financial Summary
            CardView(title: "Financial Summary", systemImage: "chart.pie.fill") {
                VStack(spacing: 16) {
                    // Net Worth
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Net Worth")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("$\(String(format: "%.2f", viewModel.netWorth))")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(viewModel.netWorth >= 0 ? .green : .red)
                    }
                    
                    Divider()
                    
                    // Total Expenses
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Expenses")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("$\(String(format: "%.2f", viewModel.totalExpenses))")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Total Savings")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("$\(String(format: "%.2f", viewModel.totalSavings))")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            
            // Recent Activity
            CardView(title: "Recent Activity", systemImage: "clock.fill") {
                VStack(alignment: .leading, spacing: 12) {
                    activityItem(
                        title: "Expense Added",
                        description: "Groceries - $150",
                        time: "2 days ago",
                        iconName: "cart.fill",
                        color: .red
                    )
                    
                    Divider()
                    
                    activityItem(
                        title: "Goal Progress",
                        description: "Hawaii Vacation - 40% complete",
                        time: "3 days ago",
                        iconName: "star.fill",
                        color: .green
                    )
                    
                    Divider()
                    
                    activityItem(
                        title: "Badge Earned",
                        description: "5 Day Workout Streak",
                        time: "1 week ago",
                        iconName: "medal.fill",
                        color: .blue
                    )
                }
            }
            
            // Stats Summary
            CardView(title: "Your Stats", systemImage: "chart.bar.fill") {
                VStack(spacing: 16) {
                    // Calculate workout streak dynamically
                    let workoutStreak = calculateWorkoutStreak()
                    statRow(title: "Workout Streak", value: "\(workoutStreak) days")
                    
                    // Calculate bills paid on time percentage
                    let paidOnTimePercentage = calculatePaidOnTimePercentage()
                    statRow(title: "Bills Paid On Time", value: "\(paidOnTimePercentage)%")
                    
                    // Calculate savings rate based on income and savings
                    let savingsRate = calculateSavingsRate()
                    statRow(title: "Savings Rate", value: "\(savingsRate)%")
                    
                    // Count completed goals
                    let completedGoalsCount = viewModel.savingsGoals.filter { $0.progress >= 1.0 }.count
                    statRow(title: "Goals Completed", value: "\(completedGoalsCount)")
                }
            }
        }
    }
    
    private var badgesView: some View {
        VStack(spacing: 20) {
            // Badges Grid
            CardView(title: "Earned Badges", systemImage: "medal.fill") { () -> AnyView in
                if viewModel.badges.isEmpty {
                    return AnyView(
                        VStack {
                            Text("No badges earned yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        }
                    )
                } else {
                    return AnyView(
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
                            ForEach(viewModel.badges) { badge in
                                BadgeView(badge: badge)
                            }
                        }
                    )
                }
            }
            
            // Sample Badges (for preview)
            CardView(title: "Available Badges", systemImage: "medal.fill") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
                    sampleBadge(name: "First Paycheck", iconName: "dollarsign.circle.fill")
                    sampleBadge(name: "100 Days Workout Streak", iconName: "figure.run")
                    sampleBadge(name: "Promotion Achieved", iconName: "arrow.up.circle.fill")
                    sampleBadge(name: "Savings Goal Reached", iconName: "star.fill")
                }
            }
        }
    }
    
    private var settingsView: some View {
        VStack(spacing: 20) {
            // Account Settings
            CardView(title: "Account Settings", systemImage: "person.fill") {
                VStack(spacing: 0) {
                    settingsRow(title: "Edit Profile", iconName: "pencil")
                    Divider()
                    settingsRow(title: "Notifications", iconName: "bell.fill")
                    Divider()
                    settingsRow(title: "Privacy", iconName: "lock.fill")
                    Divider()
                    settingsRow(title: "Appearance", iconName: "paintbrush.fill")
                }
            }
            
            // App Settings
            CardView(title: "App Settings", systemImage: "gear") {
                VStack(spacing: 0) {
                    settingsRow(title: "Currency", iconName: "dollarsign.circle.fill", value: "USD")
                    Divider()
                    settingsRow(title: "Date Format", iconName: "calendar", value: "MM/DD/YYYY")
                    Divider()
                    settingsRow(title: "Time Format", iconName: "clock.fill", value: "12-hour")
                    Divider()
                    settingsRow(title: "Default View", iconName: "eye.fill", value: "Home")
                }
            }
            
            // About
            CardView(title: "About", systemImage: "info.circle.fill") {
                VStack(spacing: 0) {
                    settingsRow(title: "Version", value: "1.0.0")
                    Divider()
                    Link(destination: URL(string: "mailto:chris@chriscelaya.com")!) {
                        settingsRow(title: "Contact Developer", iconName: "envelope.fill")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Sign Out Button
            Button(action: {
                // Sign out action
            }) {
                Text("Sign Out")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func activityItem(title: String, description: String, time: String, iconName: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .foregroundColor(color)
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(time)
                .font(.caption2)
                .foregroundColor(Color.secondary.opacity(0.7))
        }
    }
    
    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
    
    private func settingsRow(title: String, iconName: String? = nil, value: String? = nil) -> some View {
        HStack {
            if let iconName = iconName {
                Image(systemName: iconName)
                    .frame(width: 24)
                    .foregroundColor(.blue)
            }
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if value == nil {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 12)
    }
    
    private func sampleBadge(name: String, iconName: String) -> some View {
        VStack {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.gray.opacity(0.3), .gray.opacity(0.5)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: iconName)
                    .font(.system(size: 30))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Text(name)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(width: 80)
        }
    }
    
    // MARK: - Stats Calculation Methods
    
    private func calculateWorkoutStreak() -> Int {
        // Sort workout sessions by date
        let sortedSessions = viewModel.workoutSessions.sorted { $0.date < $1.date }
        
        // Check for a streak of consecutive days
        var currentStreak = 0
        var maxStreak = 0
        
        if sortedSessions.isEmpty {
            return 0
        }
        
        // Get today's date at the start of day
        let today = Calendar.current.startOfDay(for: Date())
        var currentDate = Calendar.current.startOfDay(for: sortedSessions.last!.date)
        
        // If the last workout is today, start counting from it
        if Calendar.current.isDate(currentDate, inSameDayAs: today) {
            currentStreak = 1
            
            // Check backwards for consecutive days
            for i in stride(from: sortedSessions.count - 2, through: 0, by: -1) {
                let previousDate = Calendar.current.startOfDay(for: sortedSessions[i].date)
                let expectedDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
                
                if Calendar.current.isDate(previousDate, inSameDayAs: expectedDate) {
                    currentStreak += 1
                    currentDate = previousDate
                } else {
                    break
                }
            }
            
            return currentStreak
        }
        
        // If there's no workout today, the streak is 0
        return 0
    }
    
    private func calculatePaidOnTimePercentage() -> Int {
        let allExpenses = viewModel.expenses
        if allExpenses.isEmpty {
            return 100
        }
        
        let paidExpenses = allExpenses.filter { $0.isPaid }
        return Int((Double(paidExpenses.count) / Double(allExpenses.count)) * 100)
    }
    
    private func calculateSavingsRate() -> Int {
        if viewModel.totalIncome == 0 {
            return 0
        }
        
        let savingsRate = (viewModel.totalSavings / viewModel.totalIncome) * 100
        return min(Int(savingsRate), 100)
    }
}

#Preview {
    ProfileView()
} 