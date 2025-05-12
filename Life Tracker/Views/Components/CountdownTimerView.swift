// Created by Celaya Solutions 2025
//
//  CountdownTimerView.swift
//  Life Tracker
//

import SwiftUI
import UIKit

struct CountdownTimerView: View {
    let targetDate: Date
    let title: String
    
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer?
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                timeComponent(value: years, unit: "Years")
                timeComponent(value: months, unit: "Months")
                timeComponent(value: weeks, unit: "Weeks")
            }
            
            HStack(spacing: 20) {
                timeComponent(value: days, unit: "Days")
                timeComponent(value: hours, unit: "Hours")
                timeComponent(value: minutes, unit: "Minutes")
            }
            
            timeComponent(value: seconds, unit: "Seconds")
                .frame(width: 120)
        }
        .padding()
        .background(colorScheme == .dark ? Color.black : Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .onAppear {
            updateTimeRemaining()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                updateTimeRemaining()
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func updateTimeRemaining() {
        timeRemaining = max(0, targetDate.timeIntervalSince(Date()))
    }
    
    private var seconds: Int {
        Int(timeRemaining.truncatingRemainder(dividingBy: 60))
    }
    
    private var minutes: Int {
        Int((timeRemaining / 60).truncatingRemainder(dividingBy: 60))
    }
    
    private var hours: Int {
        Int((timeRemaining / 3600).truncatingRemainder(dividingBy: 24))
    }
    
    private var days: Int {
        let totalDays = Int(timeRemaining / 86400)
        return totalDays % 30
    }
    
    private var weeks: Int {
        let totalDays = Int(timeRemaining / 86400)
        return (totalDays / 7) % 4
    }
    
    private var months: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: Date(), to: targetDate)
        return abs(components.month ?? 0) % 12
    }
    
    private var years: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: Date(), to: targetDate)
        return abs(components.year ?? 0)
    }
    
    private func timeComponent(value: Int, unit: String) -> some View {
        VStack {
            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
                .monospacedDigit()
                .frame(minWidth: 40)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct TimeRemainingView: View {
    @State private var birthDate = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
    @State private var targetAge: Double = 100
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Time Remaining in Life")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack {
                Text("Based on a \(Int(targetAge))-year lifespan")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Slider(value: $targetAge, in: 70...120, step: 1)
                    .padding(.horizontal)
                    .accentColor(.blue)
            }
            .padding(.horizontal)
            
            DatePicker("Your Birth Date", selection: $birthDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding(.horizontal)
            
            let targetDate = Calendar.current.date(byAdding: .year, value: Int(targetAge), to: birthDate) ?? Date()
            
            CountdownTimerView(
                targetDate: targetDate,
                title: "Time Remaining Until Age \(Int(targetAge))"
            )
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Your life in perspective:")
                    .font(.headline)
                    .padding(.top)
                
                let yearsLived = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
                let percentLived = Double(yearsLived) / targetAge
                
                Text("You've lived \(yearsLived) years (\(Int(percentLived * 100))% of your life)")
                    .font(.subheadline)
                
                ProgressView(value: percentLived)
                    .tint(.blue)
                    .frame(height: 8)
                
                // Additional statistics
                VStack(alignment: .leading, spacing: 8) {
                    Text("Estimated remaining:")
                        .font(.subheadline)
                        .padding(.top, 8)
                    
                    let yearsRemaining = max(0, Int(targetAge) - yearsLived)
                    
                    HStack {
                        StatView(value: yearsRemaining, unit: "years")
                        StatView(value: yearsRemaining * 12, unit: "months")
                        StatView(value: yearsRemaining * 52, unit: "weeks")
                    }
                    
                    HStack {
                        StatView(value: yearsRemaining * 365, unit: "days")
                        StatView(value: yearsRemaining * 365 * 24, unit: "hours")
                    }
                    
                    Text("Inspired by \"The Tail End\" from waitbutwhy.com")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
            }
            .padding()
            .background(colorScheme == .dark ? Color.black : Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .padding()
    }
}

struct StatView: View {
    let value: Int
    let unit: String
    
    var body: some View {
        VStack {
            Text("\(value)")
                .font(.system(.headline, design: .rounded))
                .fontWeight(.bold)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    TimeRemainingView()
} 