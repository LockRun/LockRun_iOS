//
//  PermissionManager.swift
//  LockRun
//
//  Created by 전준영 on 11/4/25.
//

import HealthKit
import FamilyControls
import CoreLocation
import UserNotifications
import AVFoundation

struct PermissionManager {
    
    private let healthStore = HKHealthStore()
    
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
    
    func requestScreenTimeAuthorization() async throws -> Bool {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            return true
        } catch {
            return false
        }
    }
    
    func requestLocationAuthorization() async -> Bool {
        let manager = CLLocationManager()
        
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .denied, .restricted:
            return false
        case .notDetermined:
            break
        default:
            break
        }
        
        return await withCheckedContinuation { cont in
            let delegate = LocationPermissionDelegate(continuation: cont)
            manager.delegate = delegate
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func requestNotificationAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }
    
    func requestCameraAuthorization() async -> Bool {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        return granted
    }
    
}

final class LocationPermissionDelegate: NSObject, CLLocationManagerDelegate {
    
    private let continuation: CheckedContinuation<Bool, Never>
    
    init(continuation: CheckedContinuation<Bool, Never>) {
        self.continuation = continuation
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            continuation.resume(returning: true)
        case .denied, .restricted:
            continuation.resume(returning: false)
        default:
            break
        }
    }
    
}
