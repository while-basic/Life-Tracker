// Created by Celaya Solutions 2025
//
//  PatternDiscoveryModels.swift
//  Life Tracker
//

import Foundation
import SwiftUI

// MARK: - Discovered Patterns

struct DiscoveredPattern: Identifiable, Codable {
    var id = UUID()
    var type: PatternType
    var title: String
    var description: String
    var confidence: Double // 0-1
    var strength: PatternStrength
    var category: PatternCategory
    var discoveredDate: Date = Date()
    var dataPoints: [DataPoint] = []
    var correlations: [Correlation] = []
    var insights: [String] = []
    var recommendations: [String] = []
    var visualizationData: VisualizationData?
    var isCritical: Bool = false // Needs immediate attention

    enum PatternType: String, Codable, CaseIterable {
        case moodCycle = "Mood Cycle"
        case sleepQuality = "Sleep Quality"
        case energyLevel = "Energy Level"
        case stressTrigger = "Stress Trigger"
        case productivityCycle = "Productivity Cycle"
        case socialPattern = "Social Pattern"
        case healthCorrelation = "Health Correlation"
        case behavioralTrend = "Behavioral Trend"
        case medicationEffect = "Medication Effect"
        case seasonalAffect = "Seasonal Affect"
        case locationBased = "Location-Based"
        case timeOfDay = "Time of Day"
        case warning = "Warning Sign"
    }

    enum PatternStrength: String, Codable, CaseIterable {
        case weak = "Weak"
        case moderate = "Moderate"
        case strong = "Strong"
        case veryStrong = "Very Strong"
    }

    enum PatternCategory: String, Codable, CaseIterable {
        case physical = "Physical Health"
        case mental = "Mental Health"
        case behavioral = "Behavioral"
        case social = "Social"
        case environmental = "Environmental"
        case temporal = "Temporal"
    }

    struct DataPoint: Codable {
        var timestamp: Date
        var value: Double
        var context: [String: String]
    }

    struct Correlation: Identifiable, Codable {
        var id = UUID()
        var variable1: String
        var variable2: String
        var correlationCoefficient: Double // -1 to 1
        var description: String
    }

    struct VisualizationData: Codable {
        var chartType: ChartType
        var dataPoints: [ChartDataPoint]
        var trendLine: [ChartDataPoint]?

        enum ChartType: String, Codable {
            case line = "Line"
            case scatter = "Scatter"
            case heatmap = "Heatmap"
            case timeline = "Timeline"
        }

        struct ChartDataPoint: Codable {
            var x: Double
            var y: Double
            var label: String?
            var color: String?
        }
    }
}

// MARK: - Pattern Analysis Result

struct PatternAnalysisResult: Codable {
    var analysisDate: Date = Date()
    var patterns: [DiscoveredPattern] = []
    var criticalFindings: [CriticalFinding] = []
    var trends: [Trend] = []
    var predictions: [Prediction] = []
    var overallHealthScore: Double? // 0-100

    struct CriticalFinding: Identifiable, Codable {
        var id = UUID()
        var severity: Severity
        var title: String
        var description: String
        var actionRequired: String
        var relatedPatterns: [UUID] = []

        enum Severity: String, Codable, CaseIterable {
            case info = "Info"
            case warning = "Warning"
            case urgent = "Urgent"
            case critical = "Critical"
        }
    }

    struct Trend: Identifiable, Codable {
        var id = UUID()
        var metric: String
        var direction: Direction
        var change: Double // Percentage change
        var timeframe: String
        var isPositive: Bool

        enum Direction: String, Codable {
            case improving = "Improving"
            case stable = "Stable"
            case declining = "Declining"
        }
    }

    struct Prediction: Identifiable, Codable {
        var id = UUID()
        var what: String
        var when: Date
        var confidence: Double // 0-1
        var basis: String
        var preventativeActions: [String] = []
    }
}

// MARK: - Health Correlations

struct HealthCorrelation: Identifiable, Codable {
    var id = UUID()
    var primaryMetric: HealthMetric
    var correlatedWith: [CorrelatedMetric] = []
    var strength: CorrelationStrength
    var timeLag: TimeInterval? // Delay between cause and effect
    var description: String

    enum HealthMetric: String, Codable, CaseIterable {
        case heartRate = "Heart Rate"
        case sleep = "Sleep"
        case steps = "Steps"
        case mood = "Mood"
        case stress = "Stress"
        case energy = "Energy"
        case medication = "Medication"
        case symptoms = "Symptoms"
        case location = "Location"
        case social = "Social Interaction"
        case weather = "Weather"
    }

    struct CorrelatedMetric: Codable {
        var metric: HealthMetric
        var correlation: Double // -1 to 1
        var description: String
    }

    enum CorrelationStrength: String, Codable {
        case weak = "Weak"
        case moderate = "Moderate"
        case strong = "Strong"
    }
}

// MARK: - Behavioral Pattern

struct BehavioralPattern: Identifiable, Codable {
    var id = UUID()
    var behavior: String
    var frequency: Frequency
    var triggers: [String] = []
    var consequences: [String] = []
    var pattern: String
    var relatedToMentalHealth: Bool = false
    var interventions: [String] = []

    enum Frequency: String, Codable {
        case rare = "Rare"
        case occasional = "Occasional"
        case frequent = "Frequent"
        case constant = "Constant"
    }
}

// MARK: - Crisis Risk Assessment

struct CrisisRiskAssessment: Codable {
    var assessmentDate: Date = Date()
    var overallRiskLevel: RiskLevel
    var riskFactors: [RiskFactor] = []
    var protectiveFactors: [String] = []
    var recommendedActions: [String] = []
    var shouldAlertEmergencyContact: Bool = false
    var shouldSuggestProfessionalHelp: Bool = false

    enum RiskLevel: String, Codable, CaseIterable {
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case severe = "Severe"
    }

    struct RiskFactor: Identifiable, Codable {
        var id = UUID()
        var factor: String
        var weight: Double // How much this contributes to risk
        var recentChange: Bool
    }
}

// MARK: - Semantic Analysis Result

struct SemanticAnalysisResult: Codable {
    var analysisDate: Date = Date()
    var overallSentiment: Double // -1 to 1
    var emotionalState: EmotionalState
    var topics: [Topic] = []
    var entities: [Entity] = []
    var linguisticMarkers: [LinguisticMarker] = []
    var concerningContent: [ConcerningContent] = []

    enum EmotionalState: String, Codable, CaseIterable {
        case veryNegative = "Very Negative"
        case negative = "Negative"
        case neutral = "Neutral"
        case positive = "Positive"
        case veryPositive = "Very Positive"
        case mixed = "Mixed"
        case manic = "Manic" // For bipolar detection
        case depressive = "Depressive"
        case anxious = "Anxious"
        case paranoid = "Paranoid" // For schizophrenia markers
    }

    struct Topic: Identifiable, Codable {
        var id = UUID()
        var name: String
        var frequency: Int
        var sentiment: Double
        var keywords: [String]
    }

    struct Entity: Identifiable, Codable {
        var id = UUID()
        var name: String
        var type: EntityType
        var sentiment: Double
        var mentions: Int

        enum EntityType: String, Codable {
            case person = "Person"
            case place = "Place"
            case organization = "Organization"
            case event = "Event"
            case medication = "Medication"
            case symptom = "Symptom"
        }
    }

    struct LinguisticMarker: Codable {
        var marker: String
        var significance: String
        var relatedTo: String? // e.g., "Mania", "Depression"
    }

    struct ConcerningContent: Identifiable, Codable {
        var id = UUID()
        var content: String
        var concernType: ConcernType
        var severity: Severity
        var context: String

        enum ConcernType: String, Codable {
            case selfHarm = "Self-Harm"
            case suicidal = "Suicidal Ideation"
            case psychosis = "Psychosis Indicator"
            case severe Mood = "Severe Mood Change"
            case dissociation = "Dissociation"
            case paranoia = "Paranoia"
        }

        enum Severity: String, Codable {
            case mild = "Mild"
            case moderate = "Moderate"
            case severe = "Severe"
            case critical = "Critical"
        }
    }
}

// MARK: - Location Pattern

struct LocationPattern: Identifiable, Codable {
    var id = UUID()
    var location: SignificantLocation
    var visits: [Visit] = []
    var averageMood: Double?
    var averageStress: Double?
    var averageHeartRate: Double?
    var associatedActivities: [String] = []
    var timePatterns: [TimePattern] = []
    var isSafe: Bool = true

    struct SignificantLocation: Codable {
        var name: String
        var category: LocationCategory
        var latitude: Double
        var longitude: Double
        var radius: Double // meters

        enum LocationCategory: String, Codable, CaseIterable {
            case home = "Home"
            case work = "Work"
            case medical = "Medical"
            case social = "Social"
            case exercise = "Exercise"
            case therapy = "Therapy"
            case other = "Other"
        }
    }

    struct Visit: Codable {
        var arrival: Date
        var departure: Date
        var duration: TimeInterval
        var moodBefore: Double?
        var moodAfter: Double?
        var healthDataSnapshot: HealthDataSnapshot?
    }

    struct TimePattern: Codable {
        var dayOfWeek: Int
        var timeRange: String
        var frequency: Int
    }
}

// MARK: - Medication Effectiveness

struct MedicationEffectiveness: Identifiable, Codable {
    var id = UUID()
    var medicationName: String
    var startDate: Date
    var measurements: [Measurement] = []
    var overallEffectiveness: Double // 0-10
    var sideEffects: [SideEffect] = []
    var adherenceRate: Double // 0-1
    var recommendations: [String] = []

    struct Measurement: Identifiable, Codable {
        var id = UUID()
        var date: Date
        var targetSymptom: String
        var severityBefore: Int // 0-10
        var severityAfter: Int // 0-10
        var timeSinceDose: TimeInterval
    }

    struct SideEffect: Identifiable, Codable {
        var id = UUID()
        var effect: String
        var severity: Int // 1-10
        var frequency: String
        var impact: String
    }
}
