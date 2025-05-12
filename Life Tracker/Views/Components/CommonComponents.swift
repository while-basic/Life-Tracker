// Created by Celaya Solutions 2025
//
//  CommonComponents.swift
//  Life Tracker
//
//  Created by Cursor on 5/11/25.
//

import SwiftUI

// MARK: - Card View

struct CardView<Content: View>: View {
    var title: String
    var systemImage: String?
    var backgroundColor: Color = Color(.systemBackground)
    var content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.headline)
                }
                
                Text(title)
                    .font(.headline)
                
                Spacer()
            }
            
            content()
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Progress Bar

struct ProgressBarView: View {
    var value: Double
    var color: Color = .blue
    var height: CGFloat = 8
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: height)
                    .opacity(0.2)
                    .foregroundColor(color)
                    .cornerRadius(height / 2)
                
                Rectangle()
                    .frame(width: min(CGFloat(value) * geometry.size.width, geometry.size.width), height: height)
                    .foregroundColor(color)
                    .cornerRadius(height / 2)
                    .animation(.linear, value: value)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Insight Card

struct InsightCardView: View {
    var insight: AIInsight
    
    var body: some View {
        CardView(
            title: insight.title,
            systemImage: "lightbulb.fill",
            backgroundColor: Color(.systemBackground)
        ) {
            Text(insight.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Event Card

struct EventCardView: View {
    var event: Event
    
    private var eventColor: Color {
        switch event.category {
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
    
    private var eventIcon: String {
        switch event.category {
        case .birthday:
            return "gift.fill"
        case .anniversary:
            return "heart.fill"
        case .meeting:
            return "person.3.fill"
        case .medication:
            return "pill.fill"
        case .doctor:
            return "cross.fill"
        case .gym:
            return "figure.strengthtraining.traditional"
        case .studio:
            return "music.note"
        case .general:
            return "calendar"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(eventColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: eventIcon)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                
                if event.isAllDay {
                    Text("All day")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else if let endTime = event.endTime {
                    Text("\(event.startTime.formatted(date: .omitted, time: .shortened)) - \(endTime.formatted(date: .omitted, time: .shortened))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text(event.startTime.formatted(date: .omitted, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let location = event.location {
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(event.startTime.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Expense Card

struct ExpenseCardView: View {
    var expense: Expense
    
    private var categoryColor: Color {
        switch expense.category {
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
    
    private var categoryIcon: String {
        switch expense.category {
        case .housing:
            return "house.fill"
        case .utilities:
            return "bolt.fill"
        case .food:
            return "fork.knife"
        case .transportation:
            return "car.fill"
        case .entertainment:
            return "tv.fill"
        case .healthcare:
            return "heart.fill"
        case .education:
            return "book.fill"
        case .personal:
            return "person.fill"
        case .debt:
            return "creditcard.fill"
        case .other:
            return "square.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(categoryColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: categoryIcon)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.name)
                    .font(.headline)
                
                Text(expense.dueDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if expense.isRecurring, let frequency = expense.recurringFrequency {
                    Text("Recurring \(frequency.rawValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text("$\(expense.amount, specifier: "%.2f")")
                .font(.headline)
                .foregroundColor(expense.isPaid ? .green : .primary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Badge View

struct BadgeView: View {
    var badge: Badge
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue.opacity(0.5), .blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: badge.iconName)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            }
            
            Text(badge.name)
                .font(.caption)
                .multilineTextAlignment(.center)
                .frame(width: 80)
        }
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    var title: String
    var message: String
    var systemImage: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
} 