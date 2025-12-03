// Created by Celaya Solutions 2025
//
//  HealthKitManager.swift
//  Life Tracker
//

import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()

    @Published var isAuthorized = false
    @Published var healthData = HealthData()

    private init() {}

    // MARK: - Authorization

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }

        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                completion(success, error)
            }
        }
    }

    // MARK: - Fetch Health Data

    func fetchAllHealthData(completion: @escaping (HealthData) -> Void) {
        let group = DispatchGroup()
        var newHealthData = HealthData()

        // Fetch heart rate
        group.enter()
        fetchHeartRate { heartRateData in
            newHealthData.heartRateData = heartRateData
            group.leave()
        }

        // Fetch steps
        group.enter()
        fetchSteps { stepsData in
            newHealthData.stepsData = stepsData
            group.leave()
        }

        // Fetch sleep
        group.enter()
        fetchSleep { sleepData in
            newHealthData.sleepData = sleepData
            group.leave()
        }

        // Fetch active energy
        group.enter()
        fetchActiveEnergy { energyData in
            newHealthData.activityData = energyData
            group.leave()
        }

        // Fetch HRV
        group.enter()
        fetchHRV { hrvData in
            newHealthData.hrvData = hrvData
            group.leave()
        }

        group.notify(queue: .main) {
            self.healthData = newHealthData
            completion(newHealthData)
        }
    }

    // MARK: - Individual Data Fetchers

    private func fetchHeartRate(completion: @escaping ([HealthData.HealthDataPoint]) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion([])
            return
        }

        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion([])
                return
            }

            let dataPoints = samples.map { sample in
                HealthData.HealthDataPoint(
                    date: sample.startDate,
                    value: sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                )
            }

            DispatchQueue.main.async {
                completion(dataPoints)
            }
        }

        healthStore.execute(query)
    }

    private func fetchSteps(completion: @escaping ([HealthData.HealthDataPoint]) -> Void) {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion([])
            return
        }

        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

        let query = HKSampleQuery(sampleType: stepsType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion([])
                return
            }

            let dataPoints = samples.map { sample in
                HealthData.HealthDataPoint(
                    date: sample.startDate,
                    value: sample.quantity.doubleValue(for: HKUnit.count())
                )
            }

            DispatchQueue.main.async {
                completion(dataPoints)
            }
        }

        healthStore.execute(query)
    }

    private func fetchSleep(completion: @escaping ([HealthData.HealthDataPoint]) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion([])
            return
        }

        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { _, samples, error in
            guard let samples = samples as? [HKCategorySample], error == nil else {
                completion([])
                return
            }

            // Group by day and calculate total sleep hours
            var sleepByDay: [Date: TimeInterval] = [:]

            for sample in samples {
                let calendar = Calendar.current
                let day = calendar.startOfDay(for: sample.startDate)

                // Only count actual sleep (asleep), not in bed
                if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue ||
                   sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                   sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                   sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue {
                    let duration = sample.endDate.timeIntervalSince(sample.startDate)
                    sleepByDay[day, default: 0] += duration
                }
            }

            let dataPoints = sleepByDay.map { day, duration in
                HealthData.HealthDataPoint(
                    date: day,
                    value: duration / 3600 // Convert to hours
                )
            }.sorted { $0.date < $1.date }

            DispatchQueue.main.async {
                completion(dataPoints)
            }
        }

        healthStore.execute(query)
    }

    private func fetchActiveEnergy(completion: @escaping ([HealthData.HealthDataPoint]) -> Void) {
        guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion([])
            return
        }

        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

        let query = HKSampleQuery(sampleType: energyType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion([])
                return
            }

            let dataPoints = samples.map { sample in
                HealthData.HealthDataPoint(
                    date: sample.startDate,
                    value: sample.quantity.doubleValue(for: HKUnit.kilocalorie())
                )
            }

            DispatchQueue.main.async {
                completion(dataPoints)
            }
        }

        healthStore.execute(query)
    }

    private func fetchHRV(completion: @escaping ([HealthData.HealthDataPoint]) -> Void) {
        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            completion([])
            return
        }

        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

        let query = HKSampleQuery(sampleType: hrvType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion([])
                return
            }

            let dataPoints = samples.map { sample in
                HealthData.HealthDataPoint(
                    date: sample.startDate,
                    value: sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
                )
            }

            DispatchQueue.main.async {
                completion(dataPoints)
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Real-time Observers

    func startObservingHeartRate(completion: @escaping (Double) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }

        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] _, _, error in
            guard error == nil else { return }

            // Fetch the latest heart rate
            self?.fetchLatestHeartRate(completion: completion)
        }

        healthStore.execute(query)
    }

    private func fetchLatestHeartRate(completion: @escaping (Double) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
            guard let sample = samples?.first as? HKQuantitySample, error == nil else { return }

            let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            DispatchQueue.main.async {
                completion(heartRate)
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Helper Methods

    func getCurrentSnapshot() -> HealthDataSnapshot {
        return healthData.latestSnapshot()
    }
}
