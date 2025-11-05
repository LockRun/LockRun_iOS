//
//  PermissionManager.swift
//  LockRun
//
//  Created by 전준영 on 11/4/25.
//

import HealthKit

struct PermissionManager {
    
    let healthStore = HKHealthStore()
    
    func requestHealthKitAuthorization() async throws -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!, // 걸음수
            HKQuantityType.quantityType(forIdentifier: .heartRate)!, // 심박수
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!, // 걷거나 달리거나 거리
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)! // 칼로리
        ]
        
        return try await withCheckedThrowingContinuation { cont in
            healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
                if let error = error { cont.resume(throwing: error) }
                else { cont.resume(returning: success) }
            }
        }
    }
    
}
