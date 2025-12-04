// Created by Celaya Solutions 2025
//
//  UserAvatarModels.swift
//  Life Tracker
//

import Foundation
import SwiftUI
import CoreLocation

// MARK: - User Avatar (Comprehensive User Profile)

struct UserAvatar: Codable {
    var id: UUID = UUID()
    var basicInfo: BasicInfo
    var medicalProfile: MedicalProfile
    var mentalHealthProfile: MentalHealthProfile
    var medications: [Medication] = []
    var lifeContext: LifeContext
    var preferences: UserPreferences
    var emergencyContacts: [EmergencyContact] = []
    var documents: [UserDocument] = []
    var lastUpdated: Date = Date()

    // MARK: - Basic Info
    struct BasicInfo: Codable {
        var name: String = ""
        var dateOfBirth: Date?
        var gender: String = ""
        var pronouns: String = ""
        var occupation: String = ""
        var location: String = ""
        var timezone: TimeZone = .current
    }

    // MARK: - Medical Profile
    struct MedicalProfile: Codable {
        var bloodType: String = ""
        var height: Measurement<UnitLength>?
        var weight: Measurement<UnitMass>?

        // Critical Medical Conditions
        var hasHeartCondition: Bool = false
        var heartConditionDetails: String = ""
        var hasPacemaker: Bool = false
        var pacemakerType: String = ""
        var pacemakerImplantDate: Date?

        // Chronic Conditions
        var chronicConditions: [ChronicCondition] = []
        var disabilities: [Disability] = []

        // Allergies & Sensitivities
        var allergies: [Allergy] = []
        var foodSensitivities: [String] = []

        // Other Medical Info
        var surgeries: [Surgery] = []
        var familyHistory: [FamilyHistoryItem] = []
        var immunizations: [Immunization] = []

        struct ChronicCondition: Identifiable, Codable {
            var id = UUID()
            var name: String
            var diagnosisDate: Date?
            var severity: Severity
            var notes: String = ""
            var impacts: [String] = [] // What does this affect?

            enum Severity: String, Codable, CaseIterable {
                case mild = "Mild"
                case moderate = "Moderate"
                case severe = "Severe"
                case critical = "Critical"
            }
        }

        struct Disability: Identifiable, Codable {
            var id = UUID()
            var type: String
            var description: String
            var accommodationsNeeded: [String] = []
        }

        struct Allergy: Identifiable, Codable {
            var id = UUID()
            var allergen: String
            var reaction: String
            var severity: AllergenSeverity

            enum AllergenSeverity: String, Codable, CaseIterable {
                case mild = "Mild"
                case moderate = "Moderate"
                case severe = "Severe"
                case anaphylactic = "Anaphylactic"
            }
        }

        struct Surgery: Identifiable, Codable {
            var id = UUID()
            var procedure: String
            var date: Date
            var notes: String = ""
        }

        struct FamilyHistoryItem: Identifiable, Codable {
            var id = UUID()
            var relation: String
            var condition: String
            var ageOfOnset: Int?
        }

        struct Immunization: Identifiable, Codable {
            var id = UUID()
            var vaccine: String
            var date: Date
            var nextDose: Date?
        }
    }

    // MARK: - Mental Health Profile
    struct MentalHealthProfile: Codable {
        var diagnoses: [MentalHealthDiagnosis] = []
        var triggers: [Trigger] = []
        var copingStrategies: [CopingStrategy] = []
        var warningSignsOfCrisis: [String] = []
        var safetyPlan: SafetyPlan?
        var therapyHistory: [TherapySession] = []

        struct MentalHealthDiagnosis: Identifiable, Codable {
            var id = UUID()
            var condition: MentalHealthCondition
            var customCondition: String? // If "other"
            var diagnosisDate: Date?
            var severity: Severity
            var currentlyManaged: Bool = true
            var notes: String = ""
            var symptoms: [String] = []
            var impacts: [String] = []

            enum MentalHealthCondition: String, Codable, CaseIterable {
                case adhd = "ADHD"
                case bipolarI = "Bipolar I"
                case bipolarII = "Bipolar II"
                case depression = "Major Depression"
                case anxiety = "Generalized Anxiety"
                case ptsd = "PTSD"
                case ocd = "OCD"
                case schizophrenia = "Schizophrenia"
                case schizoaffective = "Schizoaffective Disorder"
                case autism = "Autism Spectrum"
                case borderline = "Borderline Personality"
                case other = "Other"
            }

            enum Severity: String, Codable, CaseIterable {
                case mild = "Mild"
                case moderate = "Moderate"
                case severe = "Severe"
            }
        }

        struct Trigger: Identifiable, Codable {
            var id = UUID()
            var trigger: String
            var category: TriggerCategory
            var severity: TriggerSeverity
            var associatedConditions: [String] = []

            enum TriggerCategory: String, Codable, CaseIterable {
                case environmental = "Environmental"
                case social = "Social"
                case emotional = "Emotional"
                case sensory = "Sensory"
                case situational = "Situational"
            }

            enum TriggerSeverity: String, Codable, CaseIterable {
                case low = "Low"
                case medium = "Medium"
                case high = "High"
            }
        }

        struct CopingStrategy: Identifiable, Codable {
            var id = UUID()
            var strategy: String
            var effectiveness: Int // 1-10
            var whenToUse: String
            var category: StrategyCategory

            enum StrategyCategory: String, Codable, CaseIterable {
                case grounding = "Grounding"
                case distraction = "Distraction"
                case physical = "Physical Activity"
                case creative = "Creative Expression"
                case social = "Social Support"
                case mindfulness = "Mindfulness"
                case other = "Other"
            }
        }

        struct SafetyPlan: Codable {
            var warningSigns: [String] = []
            var copingStrategies: [String] = []
            var socialDistractions: [String] = []
            var professionalContacts: [Contact] = []
            var crisisHotlines: [Contact] = []
            var reasonsForLiving: [String] = []

            struct Contact: Codable {
                var name: String
                var phone: String
                var relationship: String
            }
        }

        struct TherapySession: Identifiable, Codable {
            var id = UUID()
            var date: Date
            var type: String // CBT, DBT, etc.
            var provider: String
            var notes: String = ""
        }
    }

    // MARK: - Medications
    struct Medication: Identifiable, Codable {
        var id = UUID()
        var name: String
        var dosage: String
        var frequency: String
        var prescribedFor: String
        var startDate: Date
        var endDate: Date?
        var sideEffects: [String] = []
        var interactions: [String] = []
        var effectiveness: Int? // 1-10
        var adherence: Double = 1.0 // 0-1
        var notes: String = ""
        var criticalMedication: Bool = false
    }

    // MARK: - Life Context
    struct LifeContext: Codable {
        // Relationships
        var relationshipStatus: String = ""
        var hasChildren: Bool = false
        var numberOfChildren: Int = 0
        var livingSituation: String = ""
        var supportSystem: [SupportPerson] = []

        // Career & Education
        var careerGoals: [String] = []
        var currentProjects: [String] = []
        var skills: [String] = []
        var learningGoals: [String] = []

        // Financial Context
        var financialSituation: FinancialSituation = .stable
        var financialGoals: [String] = []

        // Lifestyle
        var sleepSchedule: SleepSchedule?
        var dietaryPreferences: [String] = []
        var exerciseRoutine: String = ""
        var hobbies: [String] = []

        // Values & Beliefs
        var coreValues: [String] = []
        var religiousBeliefs: String = ""
        var politicalViews: String = ""

        struct SupportPerson: Identifiable, Codable {
            var id = UUID()
            var name: String
            var relationship: String
            var supportType: [String] // Emotional, practical, financial, etc.
            var trustLevel: Int // 1-10
        }

        enum FinancialSituation: String, Codable, CaseIterable {
            case struggling = "Struggling"
            case stable = "Stable"
            case comfortable = "Comfortable"
            case wealthy = "Wealthy"
        }

        struct SleepSchedule: Codable {
            var typicalBedtime: Date
            var typicalWakeTime: Date
            var averageHours: Double
            var sleepQuality: Int // 1-10
        }
    }

    // MARK: - User Preferences
    struct UserPreferences: Codable {
        // Communication Style
        var preferredCommunicationStyle: CommunicationStyle = .balanced
        var formalityLevel: Double = 0.5 // 0 = very casual, 1 = very formal
        var detailLevel: DetailLevel = .moderate
        var emojiUsage: Bool = false

        // AI Behavior
        var proactiveAlerts: Bool = true
        var crisisDetection: Bool = true
        var patternNotifications: Bool = true
        var healthReminders: Bool = true

        // Privacy & Data
        var shareLocationData: Bool = false
        var analyzeCommunications: Bool = true
        var longTermMemory: Bool = true

        // Accessibility
        var largeText: Bool = false
        var highContrast: Bool = false
        var voiceControl: Bool = false

        enum CommunicationStyle: String, Codable, CaseIterable {
            case direct = "Direct & Brief"
            case balanced = "Balanced"
            case supportive = "Warm & Supportive"
            case analytical = "Analytical & Detailed"
        }

        enum DetailLevel: String, Codable, CaseIterable {
            case brief = "Brief"
            case moderate = "Moderate"
            case detailed = "Detailed"
            case comprehensive = "Comprehensive"
        }
    }

    // MARK: - Emergency Contacts
    struct EmergencyContact: Identifiable, Codable {
        var id = UUID()
        var name: String
        var relationship: String
        var phoneNumber: String
        var email: String?
        var isPrimary: Bool = false
        var canMakeHealthDecisions: Bool = false
    }

    // MARK: - User Documents
    struct UserDocument: Identifiable, Codable {
        var id = UUID()
        var title: String
        var category: DocumentCategory
        var fileURL: URL?
        var textContent: String? // Extracted text from OCR
        var dateAdded: Date = Date()
        var tags: [String] = []
        var isImportant: Bool = false

        enum DocumentCategory: String, Codable, CaseIterable {
            case medicalRecord = "Medical Record"
            case labResult = "Lab Result"
            case prescription = "Prescription"
            case insurance = "Insurance"
            case journal = "Personal Journal"
            case mentalHealth = "Mental Health"
            case letter = "Important Letter"
            case other = "Other"
        }
    }

    // MARK: - Helper Methods
    func getContextSummary() -> String {
        var summary = "User Profile Summary:\n\n"

        // Basic Info
        if !basicInfo.name.isEmpty {
            summary += "Name: \(basicInfo.name)\n"
        }
        if !basicInfo.occupation.isEmpty {
            summary += "Occupation: \(basicInfo.occupation)\n"
        }

        // Medical Conditions
        if !medicalProfile.chronicConditions.isEmpty {
            summary += "\nChronic Conditions:\n"
            for condition in medicalProfile.chronicConditions {
                summary += "- \(condition.name) (\(condition.severity.rawValue))\n"
            }
        }

        // Mental Health
        if !mentalHealthProfile.diagnoses.isEmpty {
            summary += "\nMental Health:\n"
            for diagnosis in mentalHealthProfile.diagnoses {
                let condition = diagnosis.customCondition ?? diagnosis.condition.rawValue
                summary += "- \(condition) (\(diagnosis.severity.rawValue))\n"
            }
        }

        // Medications
        if !medications.isEmpty {
            summary += "\nMedications:\n"
            for med in medications where med.criticalMedication {
                summary += "- \(med.name) \(med.dosage) for \(med.prescribedFor)\n"
            }
        }

        // Critical Alerts
        if medicalProfile.hasPacemaker {
            summary += "\n⚠️ CRITICAL: Patient has pacemaker (\(medicalProfile.pacemakerType))\n"
        }

        return summary
    }

    func getCriticalHealthInfo() -> [String] {
        var critical: [String] = []

        if medicalProfile.hasPacemaker {
            critical.append("Pacemaker: \(medicalProfile.pacemakerType)")
        }

        for condition in medicalProfile.chronicConditions where condition.severity == .critical || condition.severity == .severe {
            critical.append("\(condition.name) (\(condition.severity.rawValue))")
        }

        for diagnosis in mentalHealthProfile.diagnoses where diagnosis.severity == .severe {
            let condition = diagnosis.customCondition ?? diagnosis.condition.rawValue
            critical.append("\(condition) (\(diagnosis.severity.rawValue))")
        }

        for med in medications where med.criticalMedication {
            critical.append("Medication: \(med.name)")
        }

        return critical
    }
}
