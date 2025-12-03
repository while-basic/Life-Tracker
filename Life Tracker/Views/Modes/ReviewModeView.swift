// Created by Celaya Solutions 2025
//
//  ReviewModeView.swift
//  Life Tracker
//

import SwiftUI
import Charts

struct ReviewModeView: View {
    @ObservedObject var viewModel: AICompanionViewModel
    @State private var selectedTimeframe: Timeframe = .week

    enum Timeframe: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Timeframe selector
                Picker("Timeframe", selection: $selectedTimeframe) {
                    ForEach(Timeframe.allCases, id: \.self) { timeframe in
                        Text(timeframe.rawValue).tag(timeframe)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Analytics overview
                AnalyticsOverview(viewModel: viewModel)

                // Sentiment trend chart
                SentimentTrendChart(
                    data: viewModel.psychoanalysisData.getSentimentTrend(days: selectedTimeframe == .week ? 7 : 30),
                    timeframe: selectedTimeframe
                )

                // Mode usage
                ModeUsageChart(analytics: viewModel.userAnalytics)

                // Communication patterns
                CommunicationPatternsCard(patterns: viewModel.psychoanalysisData.communicationPatterns)

                // Top words
                TopWordsCard(psychoanalysis: viewModel.psychoanalysisData)

                // Mood correlations
                MoodCorrelationsCard(correlations: viewModel.psychoanalysisData.moodCorrelations)

                // Ask for deeper analysis
                Button(action: requestAnalysis) {
                    Label("Request Detailed Analysis", systemImage: "sparkles")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.purple)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    private func requestAnalysis() {
        let avgSentiment = viewModel.psychoanalysisData.getAverageSentiment()
        let mostUsedMode = viewModel.userAnalytics.getMostUsedMode()?.rawValue ?? "Unknown"
        let topWords = viewModel.psychoanalysisData.getMostFrequentWords(limit: 10)

        let prompt = """
        Please analyze my patterns:

        - Average Sentiment: \(String(format: "%.2f", avgSentiment))
        - Most Used Mode: \(mostUsedMode)
        - Total Conversations: \(viewModel.userAnalytics.totalConversations)
        - Streak: \(viewModel.userAnalytics.streakDays) days
        - Top Words: \(topWords.map { $0.word }.joined(separator: ", "))

        Provide insights and recommendations for improvement.
        """

        viewModel.sendMessage(prompt) { _ in
            // Analysis complete
        }
    }
}

struct AnalyticsOverview: View {
    @ObservedObject var viewModel: AICompanionViewModel

    var body: some View {
        VStack(spacing: 12) {
            Text("Analytics Overview")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "Conversations",
                    value: "\(viewModel.userAnalytics.totalConversations)",
                    color: .blue
                )

                StatCard(
                    icon: "message.fill",
                    title: "Messages",
                    value: "\(viewModel.userAnalytics.totalMessages)",
                    color: .green
                )

                StatCard(
                    icon: "flame.fill",
                    title: "Streak",
                    value: "\(viewModel.userAnalytics.streakDays) days",
                    color: .orange
                )

                StatCard(
                    icon: "face.smiling.fill",
                    title: "Avg Sentiment",
                    value: String(format: "%.2f", viewModel.psychoanalysisData.getAverageSentiment()),
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SentimentTrendChart: View {
    let data: [PsychoanalysisData.SentimentDataPoint]
    let timeframe: ReviewModeView.Timeframe

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sentiment Trend")
                .font(.headline)
                .padding(.horizontal)

            if data.isEmpty {
                EmptyStateView(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "No Data Yet",
                    message: "Your sentiment trend will appear here as you use the app."
                )
                .padding()
            } else {
                Chart {
                    ForEach(data) { point in
                        LineMark(
                            x: .value("Date", point.timestamp),
                            y: .value("Sentiment", point.sentiment)
                        )
                        .foregroundStyle(Color.purple)

                        AreaMark(
                            x: .value("Date", point.timestamp),
                            y: .value("Sentiment", point.sentiment)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.3), Color.purple.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
                .frame(height: 200)
                .padding()
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}

struct ModeUsageChart: View {
    let analytics: UserAnalytics

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mode Usage")
                .font(.headline)
                .padding(.horizontal)

            if analytics.modeUsage.isEmpty {
                EmptyStateView(
                    icon: "chart.pie.fill",
                    title: "No Data Yet",
                    message: "Your mode usage will be tracked here."
                )
                .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(analytics.modeUsage.sorted(by: { $0.value > $1.value })), id: \.key) { mode, count in
                        HStack {
                            Image(systemName: mode.icon)
                                .foregroundColor(mode.color)

                            Text(mode.rawValue)
                                .font(.subheadline)

                            Spacer()

                            Text("\(count)")
                                .font(.headline)
                                .foregroundColor(mode.color)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}

struct CommunicationPatternsCard: View {
    let patterns: PsychoanalysisData.CommunicationPatterns

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Communication Patterns")
                .font(.headline)

            VStack(spacing: 12) {
                PatternRow(
                    title: "Average Message Length",
                    value: "\(Int(patterns.averageMessageLength)) characters"
                )

                PatternRow(
                    title: "Formality Score",
                    value: String(format: "%.0f%%", patterns.formalityScore * 100)
                )

                PatternRow(
                    title: "Complexity Score",
                    value: String(format: "%.0f%%", patterns.complexityScore * 100)
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}

struct PatternRow: View {
    let title: String
    let value: String

    var body: some View {
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
}

struct TopWordsCard: View {
    let psychoanalysis: PsychoanalysisData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Most Frequent Words")
                .font(.headline)

            let topWords = psychoanalysis.getMostFrequentWords(limit: 10)

            if topWords.isEmpty {
                EmptyStateView(
                    icon: "text.word.spacing",
                    title: "No Data Yet",
                    message: "Your word frequency will be tracked here."
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(topWords, id: \.word) { item in
                        HStack {
                            Text(item.word)
                                .font(.subheadline)

                            Spacer()

                            Text("\(item.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.purple.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}

struct MoodCorrelationsCard: View {
    let correlations: [PsychoanalysisData.MoodCorrelation]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Mood Correlations")
                .font(.headline)

            if correlations.isEmpty {
                EmptyStateView(
                    icon: "brain.head.profile",
                    title: "No Data Yet",
                    message: "Mood correlations with health data will appear here."
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(correlations.suffix(5)) { correlation in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(correlation.mood)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Spacer()

                                Text(correlation.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            HStack(spacing: 12) {
                                if let hr = correlation.heartRate {
                                    MiniMetric(icon: "heart.fill", value: "\(Int(hr))", color: .red)
                                }

                                if let steps = correlation.steps {
                                    MiniMetric(icon: "figure.walk", value: "\(steps)", color: .green)
                                }

                                if let sleep = correlation.sleepHours {
                                    MiniMetric(icon: "moon.fill", value: String(format: "%.1fh", sleep), color: .purple)
                                }
                            }

                            Divider()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}

struct MiniMetric: View {
    let icon: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)

            Text(value)
                .font(.caption2)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

#Preview {
    ReviewModeView(viewModel: AICompanionViewModel())
}
