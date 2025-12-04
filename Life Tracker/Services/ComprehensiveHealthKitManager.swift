// Created by Celaya Solutions 2025
//
//  ComprehensiveHealthKitManager.swift
//  Life Tracker
//

import Foundation
import HealthKit
import Combine

class ComprehensiveHealthKitManager: ObservableObject {
    static let shared = ComprehensiveHealthKitManager()

    private let healthStore = HKHealthStore()

    @Published var isAuthorized = false
    @Published var comprehensiveHealthData = ComprehensiveHealthData()

    private init() {}

    // MARK: - Authorization

    func requestComprehensiveAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit not available"]))
            return
        }

        let typesToRead: Set<HKObjectType> = getAllHealthKitTypes()

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                completion(success, error)
            }
        }
    }

    private func getAllHealthKitTypes() -> Set<HKObjectType> {
        var types: Set<HKObjectType> = []

        // Vitals
        if let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate) {
            types.insert(heartRate)
        }
        if let bloodPressureSystolic = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic) {
            types.insert(bloodPressureSystolic)
        }
        if let bloodPressureDiastolic = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic) {
            types.insert(bloodPressureDiastolic)
        }
        if let bodyTemp = HKQuantityType.quantityType(forIdentifier: .bodyTemperature) {
            types.insert(bodyTemp)
        }
        if let respiratoryRate = HKQuantityType.quantityType(forIdentifier: .respiratoryRate) {
            types.insert(respiratoryRate)
        }
        if let oxygenSaturation = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation) {
            types.insert(oxygenSaturation)
        }

        // Activity
        if let steps = HKQuantityType.quantityType(forIdentifier: .stepCount) {
            types.insert(steps)
        }
        if let activeEnergy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(activeEnergy)
        }
        if let distance = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
            types.insert(distance)
        }
        if let exercise = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) {
            types.insert(exercise)
        }

        // Sleep
        if let sleepAnalysis = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleepAnalysis)
        }

        // Mental Health
        if let hrv = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) {
            types.insert(hrv)
        }
        if let mindfulMinutes = HKQuantityType.quantityType(forIdentifier: .mindfulSession) {
            types.insert(mindfulMinutes)
        }

        // Nutrition
        if let dietaryEnergy = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed) {
            types.insert(dietaryEnergy)
        }
        if let water = HKQuantityType.quantityType(forIdentifier: .dietaryWater) {
            types.insert(water)
        }
        if let caffeine = HKQuantityType.quantityType(forIdentifier: .dietaryCaffeine) {
            types.insert(caffeine)
        }

        // Body Measurements
        if let weight = HKQuantityType.quantityType(forIdentifier: .bodyMass) {
            types.insert(weight)
        }
        if let height = HKQuantityType.quantityType(forIdentifier: .height) {
            types.insert(height)
        }
        if let bmi = HKQuantityType.quantityType(forIdentifier: .bodyMassIndex) {
            types.insert(bmi)
        }
        if let bodyFat = HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage) {
            types.insert(bodyFat)
        }

        // Clinical
        if let bloodGlucose = HKQuantityType.quantityType(forIdentifier: .bloodGlucose) {
            types.insert(bloodGlucose)
        }

        // Reproductive Health (if applicable)
        if let menstruation = HKObjectType.categoryType(forIdentifier: .menstrualFlow) {
            types.insert(menstruation)
        }

        // Hearing
        if let audioExposure = HKQuantityType.quantityType(forIdentifier: .environmentalAudioExposure) {
            types.insert(audioExposure)
        }

        return types
    }

    // MARK: - Fetch Comprehensive Data

    func fetchAllComprehensiveData(completion: @escaping (ComprehensiveHealthData) -> Void) {
        let group = DispatchGroup()
        var data = ComprehensiveHealthData()

        // Vitals
        group.enter()
        fetchBloodPressure { bloodPressure in
            data.bloodPressure = bloodPressure
            group.leave()
        }

        group.enter()
        fetchBodyTemperature { temp in
            data.bodyTemperature = temp
            group.leave()
        }

        group.enter()
        fetchRespiratoryRate { rate in
            data.respiratoryRate = rate
            group.leave()
        }

        group.enter()
        fetchOxygenSaturation { oxygen in
            data.oxygenSaturation = oxygen
            group.leave()
        }

        // Activity (from existing manager)
        group.enter()
        HealthKitManager.shared.fetchAllHealthData { basicData in
            data.basicHealthData = basicData
            group.leave()
        }

        // Mental Health
        group.enter()
        fetchMindfulMinutes { mindful in
            data.mindfulMinutes = mindful
            group.leave()
        }

        // Nutrition
        group.enter()
        fetchNutrition { nutrition in
            data.nutrition = nutrition
            group.leave()
        }

        // Body Measurements
        group.enter()
        fetchBodyMeasurements { measurements in
            data.bodyMeasurements = measurements
            group.leave()
        }

        // Clinical
        group.enter()
        fetchBloodGlucose { glucose in
            data.bloodGlucose = glucose
            group.leave()
        }

        group.notify(queue: .main) {
            self.comprehensiveHealthData = data
            completion(data)
        }
    }

    // MARK: - Individual Data Fetchers

    private func fetchBloodPressure(completion: @escaping ([BloodPressureReading]) -> Void) {
        guard let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic),
              let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic) else {
            completion([])
            return
        }

        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())

        // Fetch systolic and diastolic together using correlation
        let query = HKCorrelationQuery(type: HKCorrelationType.correlationType(forIdentifier: .bloodPressure)!,
                                       predicate: predicate,
                                       samplePredicates: nil) { _, correlations, error in
            guard let correlations = correlations, error == nil else {
                completion([])
                return
            }

            let readings = correlations.compactMap { correlation -> BloodPressureReading? in
                guard let systolic = correlation.objects(for: systolicType).first as? HKQuantitySample,
                      let diastolic = correlation.objects(for: diastolicType).first as? HKQuantitySample else {
                    return nil
                }

                return BloodPressureReading(
                    date: correlation.startDate,
                    systolic: systolic.quantity.doubleValue(for: HKUnit.millimeterOfMercury()),
                    diastolic: diastolic.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
                )
            }

            DispatchQueue.main.async {
                completion(readings)
            }
        }

        healthStore.execute(query)
    }

    private func fetchBodyTemperature(completion: @escaping ([BodyTemperatureReading]) -> Void) {
        guard let tempType = HKQuantityType.quantityType(forIdentifier: .bodyTemperature) else {
            completion([])
            return
        }

        fetchQuantitySamples(type: tempType, unit: .degreeFahrenheit()) { samples in
            let readings = samples.map { sample in
                BodyTemperatureReading(
                    date: sample.startDate,
                    temperature: sample.quantity.doubleValue(for: .degreeFahrenheit())
                )
            }
            completion(readings)
        }
    }

    private func fetchRespiratoryRate(completion: @escaping ([RespiratoryRateReading]) -> Void) {
        guard let respType = HKQuantityType.quantityType(forIdentifier: .respiratoryRate) else {
            completion([])
            return
        }

        fetchQuantitySamples(type: respType, unit: HKUnit.count().unitDivided(by: .minute())) { samples in
            let readings = samples.map { sample in
                RespiratoryRateReading(
                    date: sample.startDate,
                    rate: sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                )
            }
            completion(readings)
        }
    }

    private func fetchOxygenSaturation(completion: @escaping ([OxygenSaturationReading]) -> Void) {
        guard let o2Type = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation) else {
            completion([])
            return
        }

        fetchQuantitySamples(type: o2Type, unit: .percent()) { samples in
            let readings = samples.map { sample in
                OxygenSaturationReading(
                    date: sample.startDate,
                    saturation: sample.quantity.doubleValue(for: .percent()) * 100
                )
            }
            completion(readings)
        }
    }

    private func fetchMindfulMinutes(completion: @escaping ([MindfulSession]) -> Void) {
        guard let mindfulType = HKQuantityType.quantityType(forIdentifier: .mindfulSession) else {
            completion([])
            return
        }

        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())

        let query = HKSampleQuery(sampleType: mindfulType, predicate: predicate, limit: HKObjectQueryNoLimit,
                                   sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion([])
                return
            }

            let sessions = samples.map { sample in
                MindfulSession(
                    date: sample.startDate,
                    duration: sample.endDate.timeIntervalSince(sample.startDate)
                )
            }

            DispatchQueue.main.async {
                completion(sessions)
            }
        }

        healthStore.execute(query)
    }

    private func fetchNutrition(completion: @escaping (NutritionData) -> Void) {
        var nutrition = NutritionData()
        let group = DispatchGroup()

        // Caffeine
        if let caffeineType = HKQuantityType.quantityType(forIdentifier: .dietaryCaffeine) {
            group.enter()
            fetchQuantitySamples(type: caffeineType, unit: .gramUnit(with: .milli)) { samples in
                nutrition.caffeineIntake = samples.map { ($0.startDate, $0.quantity.doubleValue(for: .gramUnit(with: .milli))) }
                group.leave()
            }
        }

        // Water
        if let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) {
            group.enter()
            fetchQuantitySamples(type: waterType, unit: .literUnit(with: .milli)) { samples in
                nutrition.waterIntake = samples.map { ($0.startDate, $0.quantity.doubleValue(for: .literUnit(with: .milli))) }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(nutrition)
        }
    }

    private func fetchBodyMeasurements(completion: @escaping (BodyMeasurements) -> Void) {
        var measurements = BodyMeasurements()
        let group = DispatchGroup()

        // Weight
        if let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) {
            group.enter()
            fetchLatestQuantity(type: weightType, unit: .pound()) { value in
                measurements.latestWeight = value
                group.leave()
            }
        }

        // BMI
        if let bmiType = HKQuantityType.quantityType(forIdentifier: .bodyMassIndex) {
            group.enter()
            fetchLatestQuantity(type: bmiType, unit: .count()) { value in
                measurements.latestBMI = value
                group.leave()
            }
        }

        // Body Fat
        if let fatType = HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage) {
            group.enter()
            fetchLatestQuantity(type: fatType, unit: .percent()) { value in
                measurements.latestBodyFat = value
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(measurements)
        }
    }

    private func fetchBloodGlucose(completion: @escaping ([BloodGlucoseReading]) -> Void) {
        guard let glucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose) else {
            completion([])
            return
        }

        fetchQuantitySamples(type: glucoseType, unit: HKUnit.gramUnit(with: .milli).unitDivided(by: .literUnit(with: .deci))) { samples in
            let readings = samples.map { sample in
                BloodGlucoseReading(
                    date: sample.startDate,
                    glucose: sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .milli).unitDivided(by: .literUnit(with: .deci)))
                )
            }
            completion(readings)
        }
    }

    // MARK: - Helper Methods

    private func fetchQuantitySamples(type: HKQuantityType, unit: HKUnit, completion: @escaping ([HKQuantitySample]) -> Void) {
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())

        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit,
                                   sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion([])
                return
            }

            DispatchQueue.main.async {
                completion(samples)
            }
        }

        healthStore.execute(query)
    }

    private func fetchLatestQuantity(type: HKQuantityType, unit: HKUnit, completion: @escaping (Double?) -> Void) {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
            guard let sample = samples?.first as? HKQuantitySample, error == nil else {
                completion(nil)
                return
            }

            let value = sample.quantity.doubleValue(for: unit)
            DispatchQueue.main.async {
                completion(value)
            }
        }

        healthStore.execute(query)
    }
}

// MARK: - Comprehensive Health Data

struct ComprehensiveHealthData: Codable {
    var basicHealthData: HealthData = HealthData()

    // Vitals
    var bloodPressure: [BloodPressureReading] = []
    var bodyTemperature: [BodyTemperatureReading] = []
    var respiratoryRate: [RespiratoryRateReading] = []
    var oxygenSaturation: [OxygenSaturationReading] = []

    // Mental Health
    var mindfulMinutes: [MindfulSession] = []

    // Nutrition
    var nutrition: NutritionData = NutritionData()

    // Body Measurements
    var bodyMeasurements: BodyMeasurements = BodyMeasurements()

    // Clinical
    var bloodGlucose: [BloodGlucoseReading] = []
}

struct BloodPressureReading: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var systolic: Double
    var diastolic: Double

    var isElevated: Bool {
        return systolic >= 120 || diastolic >= 80
    }

    var isHypertensive: Bool {
        return systolic >= 130 || diastolic >= 80
    }
}

struct BodyTemperatureReading: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var temperature: Double

    var isFever: Bool {
        return temperature >= 100.4
    }
}

struct RespiratoryRateReading: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var rate: Double

    var isAbnormal: Bool {
        return rate < 12 || rate > 20
    }
}

struct OxygenSaturationReading: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var saturation: Double

    var isLow: Bool {
        return saturation < 95
    }
}

struct MindfulSession: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var duration: TimeInterval
}

struct NutritionData: Codable {
    var caffeineIntake: [(Date, Double)] = []
    var waterIntake: [(Date, Double)] = []
}

struct BodyMeasurements: Codable {
    var latestWeight: Double?
    var latestBMI: Double?
    var latestBodyFat: Double?
}

struct BloodGlucoseReading: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var glucose: Double

    var isLow: Bool {
        return glucose < 70
    }

    var isHigh: Bool {
        return glucose > 140
    }
}
