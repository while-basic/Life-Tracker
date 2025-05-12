// Created by Celaya Solutions 2025
//
//  AppTheme.swift
//  Life Tracker
//
//  Created by Cursor on 5/11/25.
//

import SwiftUI

struct AppTheme {
    // MARK: - Main Colors
    static let primary = Color.blue
    static let secondary = Color.indigo
    static let accent = Color.mint
    
    // MARK: - Status Colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue
    
    // MARK: - Text Colors
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color.gray
    
    // MARK: - Background Colors
    static let backgroundPrimary = Color(.systemBackground)
    static let backgroundSecondary = Color(.secondarySystemBackground)
    static let backgroundTertiary = Color(.tertiarySystemBackground)
    static let groupedBackground = Color(.systemGroupedBackground)
    
    // MARK: - Category Colors
    
    // Financial Categories
    static func expenseCategoryColor(_ category: Expense.ExpenseCategory) -> Color {
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
    
    // Income Sources
    static func incomeSourceColor(_ source: Income.IncomeSource) -> Color {
        switch source {
        case .salary:
            return .blue
        case .freelance:
            return .purple
        case .investment:
            return .green
        case .gift:
            return .pink
        case .other:
            return .gray
        }
    }
    
    // Event Categories
    static func eventCategoryColor(_ category: Event.EventCategory) -> Color {
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
    
    // MARK: - Icons
    
    // Financial Category Icons
    static func expenseCategoryIcon(_ category: Expense.ExpenseCategory) -> String {
        switch category {
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
    
    // Income Source Icons
    static func incomeSourceIcon(_ source: Income.IncomeSource) -> String {
        switch source {
        case .salary:
            return "briefcase.fill"
        case .freelance:
            return "laptopcomputer"
        case .investment:
            return "chart.line.uptrend.xyaxis"
        case .gift:
            return "gift.fill"
        case .other:
            return "square.fill"
        }
    }
    
    // Event Category Icons
    static func eventCategoryIcon(_ category: Event.EventCategory) -> String {
        switch category {
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
    
    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [primary, primary.opacity(0.7)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let secondaryGradient = LinearGradient(
        gradient: Gradient(colors: [secondary, secondary.opacity(0.7)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        gradient: Gradient(colors: [accent, accent.opacity(0.7)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
} 