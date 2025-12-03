// Created by Celaya Solutions 2025
//
//  AnalyticsView.swift
//  Life Tracker
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @ObservedObject var viewModel: AICompanionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Overview stats
                    OverviewStats(viewModel: viewModel)

                    // Mode breakdown
                    ModeBreakdown(analytics: viewModel.userAnalytics)

                    // Sentiment analysis
                    SentimentAnalysis(psychoanalysis: viewModel.psychoanalysisData)

                    // Activity heatmap
                    ActivityHeatmap(analytics: viewModel.userAnalytics)

                    // Insights
                    InsightsSection(viewModel: viewModel)
                }
                .padding(.vertical)
            }
            .navigationTitle("Analytics Dashboard")
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

struct OverviewStats: View {
    @ObservedObject var viewModel: AICompanionViewModel

    var body: some View {
        VStack(spacing: 12) {
            Text("Overview")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                AnalyticCard(
                    title: "Total Conversations",
                    value: "\(viewModel.userAnalytics.totalConversations)",
                    icon: "bubble.left.and.bubble.right.fill",
                    color: .blue
                )

                AnalyticCard(
                    title: "Total Messages",
                    value: "\(viewModel.userAnalytics.totalMessages)",
                    icon: "message.fill",
                    color: .green
                )

                AnalyticCard(
                    title: "Current Streak",
                    value: "\(viewModel.userAnalytics.streakDays) days",
                    icon: "flame.fill",
                    color: .orange
                )

                AnalyticCard(
                    title: "Avg Sentiment",
                    value: String(format: "%.2f", viewModel.psychoanalysisData.getAverageSentiment()),
                    icon: "face.smiling.fill",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
}

struct AnalyticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ModeBreakdown: View {
    let analytics: UserAnalytics

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mode Usage Breakdown")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)

            if analytics.modeUsage.isEmpty {
                EmptyStateView(
                    icon: "chart.pie.fill",
                    title: "No Data",
                    message: "Start using different modes to see your usage breakdown."
                )
                .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(analytics.modeUsage.sorted(by: { $0.value > $1.value })), id: \.key) { mode, count in
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: mode.icon)
                                    .foregroundColor(mode.color)
                                    .frame(width: 24)

                                Text(mode.rawValue)
                                    .font(.subheadline)
                            }

                            Spacer()

                            Text("\(count)")
                                .font(.headline)
                                .foregroundColor(mode.color)

                            let percentage = Double(count) / Double(analytics.totalConversations) * 100
                            Text(String(format: "%.0f%%", percentage))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 45, alignment: .trailing)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                .padding(.horizontal)
            }
        }
    }
}

struct SentimentAnalysis: View {
    let psychoanalysis: PsychoanalysisData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sentiment Analysis")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)

            let recentSentiment = psychoanalysis.getSentimentTrend(days: 7)

            if recentSentiment.isEmpty {
                EmptyStateView(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "No Data",
                    message: "Your sentiment data will appear here as you interact."
                )
                .padding()
            } else {
                VStack(spacing: 12) {
                    // Average sentiment
                    HStack {
                        Text("7-Day Average")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        let avg = recentSentiment.reduce(0) { $0 + $1.sentiment } / Double(recentSentiment.count)
                        Text(String(format: "%.2f", avg))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(sentimentColor(avg))
                    }
                    .padding(.horizontal)

                    // Chart
                    Chart {
                        ForEach(recentSentiment) { point in
                            LineMark(
                                x: .value("Date", point.timestamp),
                                y: .value("Sentiment", point.sentiment)
                            )
                            .foregroundStyle(Color.purple)

                            PointMark(
                                x: .value("Date", point.timestamp),
                                y: .value("Sentiment", point.sentiment)
                            )
                            .foregroundStyle(Color.purple)
                        }

                        // Zero baseline
                        RuleMark(y: .value("Neutral", 0))
                            .foregroundStyle(Color.gray.opacity(0.3))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                .padding(.horizontal)
            }
        }
    }

    private func sentimentColor(_ sentiment: Double) -> Color {
        switch sentiment {
        case 0.5...1.0: return .green
        case 0.2..<0.5: return .blue
        case -0.2..<0.2: return .orange
        default: return .red
        }
    }
}

struct ActivityHeatmap: View {
    let analytics: UserAnalytics

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity Pattern")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)

            Text("Most active time: \(analytics.mostActiveTime.isEmpty ? "Not enough data" : analytics.mostActiveTime)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            // Placeholder for future heatmap implementation
            HStack {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)

                    Text("Activity heatmap coming soon")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            .padding(.horizontal)
        }
    }
}

struct InsightsSection: View {
    @ObservedObject var viewModel: AICompanionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Insights")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)

            VStack(spacing: 12) {
                if let mostUsedMode = viewModel.userAnalytics.getMostUsedMode() {
                    InsightCard(
                        icon: mostUsedMode.icon,
                        color: mostUsedMode.color,
                        title: "Preferred Mode",
                        description: "You use \(mostUsedMode.rawValue) most often. This suggests you prefer \(mostUsedMode.description.lowercased())."
                    )
                }

                let avgSentiment = viewModel.psychoanalysisData.getAverageSentiment()
                InsightCard(
                    icon: "face.smiling.fill",
                    color: avgSentiment > 0 ? .green : .orange,
                    title: "Overall Mood",
                    description: "Your average sentiment is \(avgSentiment > 0 ? "positive" : "neutral"). Keep engaging with topics that interest you!"
                )

                if viewModel.userAnalytics.streakDays > 3 {
                    InsightCard(
                        icon: "flame.fill",
                        color: .orange,
                        title: "Great Consistency",
                        description: "You've maintained a \(viewModel.userAnalytics.streakDays)-day streak! Consistent engagement leads to better insights."
                    )
                }

                let topWords = viewModel.psychoanalysisData.getMostFrequentWords(limit: 3)
                if !topWords.isEmpty {
                    InsightCard(
                        icon: "text.word.spacing",
                        color: .purple,
                        title: "Focus Areas",
                        description: "You frequently discuss: \(topWords.map { $0.word }.joined(separator: ", ")). These might be your current priorities."
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct InsightCard: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    AnalyticsView(viewModel: AICompanionViewModel())
}
