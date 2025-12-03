// Created by Celaya Solutions 2025
//
//  ChessModeView.swift
//  Life Tracker
//

import SwiftUI

struct ChessModeView: View {
    @ObservedObject var viewModel: AICompanionViewModel

    @State private var scenario = ""
    @State private var analyses: [ChessModeAnalysis] = []
    @State private var selectedAnalysis: ChessModeAnalysis?
    @State private var showingAnalysisDetail = false
    @State private var isAnalyzing = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                        .font(.title2)

                    VStack(alignment: .leading) {
                        Text("Strategic Analysis")
                            .font(.headline)

                        Text("Using all available data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }

                // Data sources indicator
                DataSourcesIndicator()
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)

            // Previous analyses
            if !analyses.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(analyses) { analysis in
                            AnalysisChip(analysis: analysis) {
                                selectedAnalysis = analysis
                                showingAnalysisDetail = true
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
            }

            // Main content
            ScrollView {
                VStack(spacing: 20) {
                    // Scenario input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Describe Your Scenario")
                            .font(.headline)

                        Text("I'll analyze it strategically using your health data, communication patterns, and behavioral insights.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        TextField("What decision or situation do you want to analyze?", text: $scenario, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(5...10)

                        Button(action: performAnalysis) {
                            HStack {
                                if isAnalyzing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "sparkles")
                                }

                                Text(isAnalyzing ? "Analyzing..." : "Analyze with Chess Mode")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(scenario.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isAnalyzing ? Color.gray : Color.yellow)
                            .cornerRadius(10)
                        }
                        .disabled(scenario.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isAnalyzing)
                    }
                    .padding()

                    // Quick analysis prompts
                    QuickAnalysisPrompts(onSelect: { prompt in
                        scenario = prompt
                    })

                    // Example use cases
                    ExampleUseCases()
                }
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $showingAnalysisDetail) {
            if let analysis = selectedAnalysis {
                AnalysisDetailView(analysis: analysis)
            }
        }
    }

    private func performAnalysis() {
        let trimmedScenario = scenario.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedScenario.isEmpty else { return }

        isAnalyzing = true

        // Perform Chess Mode analysis
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let analysis = viewModel.performChessAnalysis(scenario: trimmedScenario)
            analyses.insert(analysis, at: 0)

            // Also send to conversation
            viewModel.sendMessage("Analyze this scenario strategically: \(trimmedScenario)") { _ in
                isAnalyzing = false
                selectedAnalysis = analysis
                showingAnalysisDetail = true
                scenario = ""
            }
        }
    }
}

struct DataSourcesIndicator: View {
    @ObservedObject private var healthKitManager = HealthKitManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Active Data Sources")
                .font(.caption)
                .foregroundColor(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    DataSourceBadge(icon: "heart.fill", label: "Heart Rate", isActive: !healthKitManager.healthData.heartRateData.isEmpty, color: .red)

                    DataSourceBadge(icon: "figure.walk", label: "Steps", isActive: !healthKitManager.healthData.stepsData.isEmpty, color: .green)

                    DataSourceBadge(icon: "moon.fill", label: "Sleep", isActive: !healthKitManager.healthData.sleepData.isEmpty, color: .purple)

                    DataSourceBadge(icon: "brain.head.profile", label: "Patterns", isActive: true, color: .blue)

                    DataSourceBadge(icon: "chart.line.uptrend.xyaxis", label: "Sentiment", isActive: true, color: .orange)
                }
            }
        }
    }
}

struct DataSourceBadge: View {
    let icon: String
    let label: String
    let isActive: Bool
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(isActive ? color : .gray)

            Text(label)
                .font(.caption2)

            if isActive {
                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isActive ? color.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AnalysisChip: View {
    let analysis: ChessModeAnalysis
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(analysis.scenario)
                    .font(.caption)
                    .lineLimit(2)

                Text(analysis.createdDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(width: 150)
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.yellow, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickAnalysisPrompts: View {
    let onSelect: (String) -> Void

    let prompts = [
        "Should I start a new business venture now?",
        "Is this the right time for a major life change?",
        "How can I optimize my decision-making process?",
        "What's my best strategic move in this situation?"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Prompts")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(prompts, id: \.self) { prompt in
                        Button(action: {
                            onSelect(prompt)
                        }) {
                            Text(prompt)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray6))
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct ExampleUseCases: View {
    let examples = [
        ("Business Decisions", "Analyze market entry, partnerships, hiring decisions", "briefcase.fill"),
        ("Personal Growth", "Career changes, relationship decisions, lifestyle shifts", "person.fill"),
        ("Financial Strategy", "Investment timing, major purchases, budget optimization", "dollarsign.circle.fill"),
        ("Health & Wellness", "Optimize routines based on your physiological data", "heart.text.square.fill")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Example Use Cases")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 12) {
                ForEach(examples, id: \.0) { example in
                    HStack(spacing: 12) {
                        Image(systemName: example.2)
                            .font(.title3)
                            .foregroundColor(.yellow)
                            .frame(width: 40)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(example.0)
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text(example.1)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct AnalysisDetailView: View {
    let analysis: ChessModeAnalysis
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Scenario
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Scenario")
                            .font(.headline)

                        Text(analysis.scenario)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.yellow.opacity(0.1))
                            .cornerRadius(10)
                    }

                    // Data Points Used
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Data Points Analyzed")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(analysis.dataPoints, id: \.self) { dataPoint in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)

                                    Text(dataPoint)
                                        .font(.caption)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }

                    // SWOT Analysis
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SWOT Analysis")
                            .font(.headline)

                        SWOTSection(title: "Strengths", items: analysis.strengths, color: .green)
                        SWOTSection(title: "Weaknesses", items: analysis.weaknesses, color: .orange)
                        SWOTSection(title: "Opportunities", items: analysis.opportunities, color: .blue)
                        SWOTSection(title: "Threats", items: analysis.threats, color: .red)
                    }

                    // Recommendations
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Strategic Recommendations")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(analysis.recommendations.enumerated()), id: \.offset) { index, recommendation in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("\(index + 1).")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.yellow)

                                    Text(recommendation)
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(10)
                    }

                    // Metadata
                    Text("Analyzed on \(analysis.createdDate.formatted(date: .long, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
            }
            .navigationTitle("Chess Mode Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SWOTSection: View {
    let title: String
    let items: [String]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "square.fill")
                    .foregroundColor(color)
                    .font(.caption)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            if items.isEmpty {
                Text("None identified")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 20)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(items, id: \.self) { item in
                        Text("• \(item)")
                            .font(.caption)
                    }
                }
                .padding(.leading, 20)
            }
        }
    }
}

#Preview {
    ChessModeView(viewModel: AICompanionViewModel())
}
