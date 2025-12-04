// Created by Celaya Solutions 2025
//
//  PatternDiscoveryEngine.swift
//  Life Tracker
//

import Foundation
import Combine
import NaturalLanguage

class PatternDiscoveryEngine: ObservableObject {
    static let shared = PatternDiscoveryEngine()

    @Published var discoveredPatterns: [DiscoveredPattern] = []
    @Published var latestAnalysis: PatternAnalysisResult?
    @Published var criticalAlerts: [PatternAnalysisResult.CriticalFinding] = []

    private init() {}

    // MARK: - Main Analysis

    func analyzeAllData(
        userAvatar: UserAvatar,
        healthData: ComprehensiveHealthData,
        conversations: [Conversation],
        journalEntries: [JournalEntry],
        psychoanalysisData: PsychoanalysisData
    ) -> PatternAnalysisResult {
        var result = PatternAnalysisResult()

        // 1. Analyze health correlations
        let healthPatterns = analyzeHealthCorrelations(healthData: healthData, userAvatar: userAvatar)
        result.patterns.append(contentsOf: healthPatterns)

        // 2. Analyze mood patterns
        let moodPatterns = analyzeMoodPatterns(psychoanalysisData: psychoanalysisData, healthData: healthData)
        result.patterns.append(contentsOf: moodPatterns)

        // 3. Analyze medication effectiveness
        if !userAvatar.medications.isEmpty {
            let medPatterns = analyzeMedicationEffectiveness(medications: userAvatar.medications, healthData: healthData, psychoanalysisData: psychoanalysisData)
            result.patterns.append(contentsOf: medPatterns)
        }

        // 4. Analyze behavioral patterns
        let behavioralPatterns = analyzeBehavioralPatterns(conversations: conversations, psychoanalysisData: psychoanalysisData)
        result.patterns.append(contentsOf: behavioralPatterns)

        // 5. Crisis risk assessment (for mental health conditions)
        if !userAvatar.mentalHealthProfile.diagnoses.isEmpty {
            let riskAssessment = assessCrisisRisk(userAvatar: userAvatar, psychoanalysisData: psychoanalysisData, conversations: conversations)
            result.criticalFindings.append(contentsOf: riskAssessment)
        }

        // 6. Identify trends
        result.trends = identifyTrends(healthData: healthData, psychoanalysisData: psychoanalysisData)

        // 7. Generate predictions
        result.predictions = generatePredictions(patterns: result.patterns, userAvatar: userAvatar)

        // 8. Overall health score
        result.overallHealthScore = calculateOverallHealthScore(patterns: result.patterns, trends: result.trends)

        // Update published properties
        DispatchQueue.main.async {
            self.discoveredPatterns = result.patterns
            self.latestAnalysis = result
            self.criticalAlerts = result.criticalFindings.filter { $0.severity == .critical || $0.severity == .urgent }
        }

        return result
    }

    // MARK: - Health Correlation Analysis

    private func analyzeHealthCorrelations(healthData: ComprehensiveHealthData, userAvatar: UserAvatar) -> [DiscoveredPattern] {
        var patterns: [DiscoveredPattern] = []

        // Heart Rate Variability (HRV) and Stress
        if !healthData.basicHealthData.hrvData.isEmpty {
            let avgHRV = healthData.basicHealthData.hrvData.map { $0.value }.reduce(0, +) / Double(healthData.basicHealthData.hrvData.count)

            if avgHRV < 30 {
                var pattern = DiscoveredPattern(
                    type: .healthCorrelation,
                    title: "Low Heart Rate Variability Detected",
                    description: "Your average HRV is \(String(format: "%.1f", avgHRV)) ms, indicating elevated stress levels.",
                    confidence: 0.85,
                    strength: .strong,
                    category: .physical
                )

                pattern.insights = [
                    "Low HRV is associated with increased stress and reduced recovery",
                    "This may affect decision-making and emotional regulation",
                    "Common in individuals with ADHD and bipolar disorder during stress periods"
                ]

                pattern.recommendations = [
                    "Practice deep breathing exercises (4-7-8 breathing)",
                    "Ensure 7-9 hours of quality sleep",
                    "Consider meditation or mindfulness practices",
                    "Review medication timing with your doctor if applicable"
                ]

                if userAvatar.mentalHealthProfile.diagnoses.contains(where: { $0.condition == .bipolar I || $0.condition == .bipolarII }) {
                    pattern.recommendations.append("Monitor for manic or depressive episode triggers")
                    pattern.isCritical = true
                }

                patterns.append(pattern)
            }
        }

        // Sleep and Mood
        if !healthData.basicHealthData.sleepData.isEmpty {
            let avgSleep = healthData.basicHealthData.sleepData.map { $0.value }.reduce(0, +) / Double(healthData.basicHealthData.sleepData.count)

            if avgSleep < 6 {
                var pattern = DiscoveredPattern(
                    type: .sleepQuality,
                    title: "Chronic Sleep Deprivation",
                    description: "Your average sleep is only \(String(format: "%.1f", avgSleep)) hours, well below recommended levels.",
                    confidence: 0.9,
                    strength: .veryStrong,
                    category: .physical
                )

                pattern.insights = [
                    "Sleep deprivation can trigger manic episodes in bipolar disorder",
                    "Lack of sleep worsens ADHD symptoms significantly",
                    "Sleep is critical for schizophrenia symptom management"
                ]

                pattern.recommendations = [
                    "URGENT: Establish consistent sleep schedule",
                    "Avoid screens 1 hour before bedtime",
                    "Review medications that may affect sleep",
                    "Consult psychiatrist if sleep issues persist"
                ]

                pattern.isCritical = true
                patterns.append(pattern)
            }
        }

        // Blood Pressure (important with pacemaker)
        if userAvatar.medicalProfile.hasPacemaker && !healthData.bloodPressure.isEmpty {
            let elevatedReadings = healthData.bloodPressure.filter { $0.isElevated }

            if Double(elevatedReadings.count) / Double(healthData.bloodPressure.count) > 0.3 {
                var pattern = DiscoveredPattern(
                    type: .healthCorrelation,
                    title: "Elevated Blood Pressure with Pacemaker",
                    description: "\(elevatedReadings.count) of \(healthData.bloodPressure.count) readings show elevated BP.",
                    confidence: 1.0,
                    strength: .veryStrong,
                    category: .physical
                )

                pattern.insights = [
                    "Elevated BP with pacemaker requires medical attention",
                    "May indicate pacemaker settings need adjustment",
                    "Stress and anxiety can elevate BP"
                ]

                pattern.recommendations = [
                    "URGENT: Contact cardiologist immediately",
                    "Monitor BP daily and log readings",
                    "Avoid caffeine and reduce sodium intake"
                ]

                pattern.isCritical = true
                patterns.append(pattern)
            }
        }

        return patterns
    }

    // MARK: - Mood Pattern Analysis

    private func analyzeMoodPatterns(psychoanalysisData: PsychoanalysisData, healthData: ComprehensiveHealthData) -> [DiscoveredPattern] {
        var patterns: [DiscoveredPattern] = []

        if psychoanalysisData.sentimentHistory.isEmpty {
            return patterns
        }

        // Analyze mood cycles (important for bipolar)
        let sentimentValues = psychoanalysisData.sentimentHistory.map { $0.sentiment }
        let avgSentiment = sentimentValues.reduce(0, +) / Double(sentimentValues.count)
        let variance = sentimentValues.map { pow($0 - avgSentiment, 2) }.reduce(0, +) / Double(sentimentValues.count)
        let stdDev = sqrt(variance)

        // High variance suggests mood cycling
        if stdDev > 0.4 {
            var pattern = DiscoveredPattern(
                type: .moodCycle,
                title: "Significant Mood Variability Detected",
                description: "Your mood shows high variability (SD: \(String(format: "%.2f", stdDev))), suggesting potential mood cycling.",
                confidence: 0.8,
                strength: .strong,
                category: .mental
            )

            pattern.insights = [
                "Mood cycling is characteristic of bipolar disorder",
                "High mood variability affects decision consistency",
                "Pattern may correlate with sleep and stress levels"
            ]

            pattern.recommendations = [
                "Track mood daily with specific ratings",
                "Note any triggers for mood shifts",
                "Discuss with psychiatrist - may indicate medication adjustment needed",
                "Use Chess Mode during stable periods for important decisions"
            ]

            pattern.isCritical = true
            patterns.append(pattern)
        }

        // Detect potential manic/depressive episodes
        let recentSentiment = psychoanalysisData.getSentimentTrend(days: 7)
        if !recentSentiment.isEmpty {
            let recentAvg = recentSentiment.map { $0.sentiment }.reduce(0, +) / Double(recentSentiment.count)

            // Potential manic episode
            if recentAvg > 0.7 {
                var pattern = DiscoveredPattern(
                    type: .warning,
                    title: "Elevated Mood Pattern - Monitor for Mania",
                    description: "Recent mood significantly elevated (avg: \(String(format: "%.2f", recentAvg))). This may indicate manic symptoms.",
                    confidence: 0.75,
                    strength: .strong,
                    category: .mental
                )

                pattern.insights = [
                    "Sustained elevated mood can be manic episode warning sign",
                    "Often accompanied by decreased sleep need and racing thoughts",
                    "Early intervention is critical"
                ]

                pattern.recommendations = [
                    "URGENT: Contact psychiatrist if you notice: decreased sleep, racing thoughts, impulsive behavior",
                    "Avoid major decisions during this period",
                    "Ensure medication adherence",
                    "Ask trusted person to help monitor behavior"
                ]

                pattern.isCritical = true
                patterns.append(pattern)
            }

            // Potential depressive episode
            if recentAvg < -0.3 {
                var pattern = DiscoveredPattern(
                    type: .warning,
                    title: "Depressed Mood Pattern Detected",
                    description: "Recent mood significantly low (avg: \(String(format: "%.2f", recentAvg))). Monitor for depressive symptoms.",
                    confidence: 0.75,
                    strength: .strong,
                    category: .mental
                )

                pattern.insights = [
                    "Sustained low mood may indicate depressive episode",
                    "Common in both bipolar disorder and major depression",
                    "Can affect motivation and decision-making"
                ]

                pattern.recommendations = [
                    "Reach out to support system",
                    "Contact therapist/psychiatrist if symptoms persist >2 weeks",
                    "Maintain routine even when difficult",
                    "Use safety plan if suicidal thoughts occur"
                ]

                pattern.isCritical = true
                patterns.append(pattern)
            }
        }

        return patterns
    }

    // MARK: - Medication Effectiveness

    private func analyzeMedicationEffectiveness(medications: [UserAvatar.Medication], healthData: ComprehensiveHealthData, psychoanalysisData: PsychoanalysisData) -> [DiscoveredPattern] {
        var patterns: [DiscoveredPattern] = []

        // Analyze if sentiment improved after medication start
        for medication in medications where medication.effectiveness != nil {
            if let effectiveness = medication.effectiveness, effectiveness < 5 {
                var pattern = DiscoveredPattern(
                    type: .medicationEffect,
                    title: "Low Medication Effectiveness: \(medication.name)",
                    description: "You rated \(medication.name) as \(effectiveness)/10 effective for \(medication.prescribedFor).",
                    confidence: 0.9,
                    strength: .strong,
                    category: .physical
                )

                pattern.insights = [
                    "Low effectiveness may indicate need for dosage adjustment",
                    "Medication may need to be changed",
                    "Side effects may outweigh benefits"
                ]

                pattern.recommendations = [
                    "Discuss with prescribing physician",
                    "Document specific symptoms that aren't improving",
                    "Note any side effects experienced",
                    "Do not discontinue without medical guidance"
                ]

                patterns.append(pattern)
            }
        }

        return patterns
    }

    // MARK: - Behavioral Pattern Analysis

    private func analyzeBehavioralPatterns(conversations: [Conversation], psychoanalysisData: PsychoanalysisData) -> [DiscoveredPattern] {
        var patterns: [DiscoveredPattern] = []

        // Analyze conversation timing patterns
        let conversationHours = conversations.map { Calendar.current.component(.hour, from: $0.startDate) }

        if conversationHours.filter({ $0 >= 22 || $0 <= 4 }).count > conversations.count / 3 {
            var pattern = DiscoveredPattern(
                type: .behavioralTrend,
                title: "Late-Night Activity Pattern",
                description: "Over 33% of your conversations occur between 10 PM and 4 AM.",
                confidence: 0.85,
                strength: .strong,
                category: .behavioral
            )

            pattern.insights = [
                "Late-night activity often indicates insomnia or altered sleep patterns",
                "Can be sign of manic episode in bipolar disorder",
                "ADHD often causes delayed sleep phase"
            ]

            pattern.recommendations = [
                "Establish consistent bedtime routine",
                "Limit stimulating activities after 9 PM",
                "Consider melatonin or sleep aid (with doctor approval)",
                "Track if this correlates with mood changes"
            ]

            patterns.append(pattern)
        }

        // Analyze communication patterns
        let avgMessageLength = psychoanalysisData.communicationPatterns.averageMessageLength

        if avgMessageLength > 500 {
            var pattern = DiscoveredPattern(
                type: .behavioralTrend,
                title: "Verbose Communication Pattern",
                description: "Average message length is \(Int(avgMessageLength)) characters, significantly above typical.",
                confidence: 0.7,
                strength: .moderate,
                category: .behavioral
            )

            pattern.insights = [
                "Pressured speech/writing can indicate manic symptoms",
                "Also common with ADHD hyperfocus",
                "May reflect racing thoughts"
            ]

            pattern.recommendations = [
                "Monitor if this increases - may signal mood elevation",
                "Practice brief, focused communication",
                "Note if accompanied by other symptoms"
            ]

            patterns.append(pattern)
        }

        return patterns
    }

    // MARK: - Crisis Risk Assessment

    private func assessCrisisRisk(userAvatar: UserAvatar, psychoanalysisData: PsychoanalysisData, conversations: [Conversation]) -> [PatternAnalysisResult.CriticalFinding] {
        var findings: [PatternAnalysisResult.CriticalFinding] = []

        // Check for warning signs in recent conversations
        let recentConversations = conversations.filter {
            $0.startDate > Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        }

        let recentMessages = recentConversations.flatMap { $0.messages.filter { $0.role == .user } }
        let recentContent = recentMessages.map { $0.content.lowercased() }.joined(separator: " ")

        // Crisis keywords
        let suicidalKeywords = ["kill myself", "end it all", "no reason to live", "better off dead", "suicide"]
        let psychosisKeywords = ["they're watching", "voices telling", "controlled by", "reading my thoughts"]
        let severeDepressionKeywords = ["can't go on", "hopeless", "worthless", "nothing matters"]

        // Check for suicidal ideation
        if suicidalKeywords.contains(where: { recentContent.contains($0) }) {
            findings.append(PatternAnalysisResult.CriticalFinding(
                severity: .critical,
                title: "CRISIS: Suicidal Ideation Detected",
                description: "Recent conversations contain language suggesting suicidal thoughts.",
                actionRequired: "IMMEDIATE ACTION: Contact crisis hotline (988), emergency contact, or go to emergency room. Use safety plan."
            ))
        }

        // Check for psychosis markers (schizophrenia)
        if userAvatar.mentalHealthProfile.diagnoses.contains(where: { $0.condition == .schizophrenia || $0.condition == .schizoaffective }) {
            if psychosisKeywords.contains(where: { recentContent.contains($0) }) {
                findings.append(PatternAnalysisResult.CriticalFinding(
                    severity: .urgent,
                    title: "Possible Psychotic Symptoms",
                    description: "Language patterns suggest potential psychotic symptoms or increased paranoia.",
                    actionRequired: "Contact psychiatrist within 24 hours. Ensure medication adherence. Avoid stressful situations."
                ))
            }
        }

        // Check mood pattern for bipolar rapid cycling
        if userAvatar.mentalHealthProfile.diagnoses.contains(where: { $0.condition == .bipolarI || $0.condition == .bipolarII }) {
            let recentSentiment = psychoanalysisData.getSentimentTrend(days: 14)
            if recentSentiment.count > 7 {
                let changes = zip(recentSentiment, recentSentiment.dropFirst()).map { abs($0.0.sentiment - $0.1.sentiment) }
                let avgChange = changes.reduce(0, +) / Double(changes.count)

                if avgChange > 0.5 {
                    findings.append(PatternAnalysisResult.CriticalFinding(
                        severity: .urgent,
                        title: "Rapid Mood Cycling Detected",
                        description: "Mood shifting significantly over short periods - may indicate rapid cycling bipolar.",
                        actionRequired: "Schedule appointment with psychiatrist. May need medication adjustment. Maintain strict sleep schedule."
                    ))
                }
            }
        }

        return findings
    }

    // MARK: - Trend Identification

    private func identifyTrends(healthData: ComprehensiveHealthData, psychoanalysisData: PsychoanalysisData) -> [PatternAnalysisResult.Trend] {
        var trends: [PatternAnalysisResult.Trend] = []

        // Sleep trend
        if healthData.basicHealthData.sleepData.count >= 7 {
            let recent = healthData.basicHealthData.sleepData.suffix(7)
            let older = healthData.basicHealthData.sleepData.dropLast(7).suffix(7)

            if !older.isEmpty {
                let recentAvg = recent.map { $0.value }.reduce(0, +) / Double(recent.count)
                let olderAvg = older.map { $0.value }.reduce(0, +) / Double(older.count)
                let change = ((recentAvg - olderAvg) / olderAvg) * 100

                let direction: PatternAnalysisResult.Trend.Direction = change > 5 ? .improving : change < -5 ? .declining : .stable

                trends.append(PatternAnalysisResult.Trend(
                    metric: "Sleep Duration",
                    direction: direction,
                    change: change,
                    timeframe: "Past 7 days vs prior 7 days",
                    isPositive: direction == .improving
                ))
            }
        }

        // Mood trend
        if psychoanalysisData.sentimentHistory.count >= 14 {
            let recent = psychoanalysisData.sentimentHistory.suffix(7)
            let older = psychoanalysisData.sentimentHistory.dropLast(7).suffix(7)

            let recentAvg = recent.map { $0.sentiment }.reduce(0, +) / Double(recent.count)
            let olderAvg = older.map { $0.sentiment }.reduce(0, +) / Double(older.count)
            let change = ((recentAvg - olderAvg) / abs(olderAvg + 0.001)) * 100

            let direction: PatternAnalysisResult.Trend.Direction = change > 10 ? .improving : change < -10 ? .declining : .stable

            trends.append(PatternAnalysisResult.Trend(
                metric: "Overall Mood",
                direction: direction,
                change: change,
                timeframe: "Past 7 days vs prior 7 days",
                isPositive: direction == .improving
            ))
        }

        return trends
    }

    // MARK: - Predictions

    private func generatePredictions(patterns: [DiscoveredPattern], userAvatar: UserAvatar) -> [PatternAnalysisResult.Prediction] {
        var predictions: [PatternAnalysisResult.Prediction] = []

        // Predict based on patterns
        for pattern in patterns {
            switch pattern.type {
            case .moodCycle:
                if pattern.strength == .strong || pattern.strength == .veryStrong {
                    predictions.append(PatternAnalysisResult.Prediction(
                        what: "Mood shift likely in next 3-7 days based on historical pattern",
                        when: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
                        confidence: pattern.confidence,
                        basis: "Historical mood cycling pattern",
                        preventativeActions: [
                            "Maintain sleep schedule",
                            "Monitor for early warning signs",
                            "Have emergency contact ready"
                        ]
                    ))
                }

            case .sleepQuality:
                predictions.append(PatternAnalysisResult.Prediction(
                    what: "Continued sleep deprivation may trigger mood episode",
                    when: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                    confidence: 0.7,
                    basis: "Sleep deprivation is known trigger for bipolar episodes",
                    preventativeActions: [
                        "Prioritize sleep tonight",
                        "Cancel non-essential commitments",
                        "Consider sleep aid if approved by doctor"
                    ]
                ))

            default:
                break
            }
        }

        return predictions
    }

    // MARK: - Health Score Calculation

    private func calculateOverallHealthScore(patterns: [DiscoveredPattern], trends: [PatternAnalysisResult.Trend]) -> Double {
        var score = 100.0

        // Deduct for critical patterns
        for pattern in patterns where pattern.isCritical {
            score -= 15
        }

        // Deduct for negative patterns
        for pattern in patterns where !pattern.isCritical {
            switch pattern.strength {
            case .weak: score -= 2
            case .moderate: score -= 5
            case .strong: score -= 8
            case .veryStrong: score -= 10
            }
        }

        // Adjust for trends
        for trend in trends {
            if trend.direction == .improving && trend.isPositive {
                score += 5
            } else if trend.direction == .declining && !trend.isPositive {
                score -= 5
            }
        }

        return max(0, min(100, score))
    }
}
