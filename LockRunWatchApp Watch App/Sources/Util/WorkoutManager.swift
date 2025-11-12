//
//  WorkoutManager.swift
//  LockRunWatchApp Watch App
//
//  Created by 전준영 on 11/5/25.
//

import HealthKit
import Combine
import WatchConnectivity

final class WorkoutManager: NSObject,
                            ObservableObject,
                            HKWorkoutSessionDelegate,
                            HKLiveWorkoutBuilderDelegate {
    
    static let shared = WorkoutManager()
    
    @Published var heartRate: Int = 0
    
    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private let wcSession = WCSession.default
    
    override init() {
        super.init()
    }
    
    // 운동 시작
    func start() {
        requestAuthorizationIfNeededAndStart()
    }
    
    private func requestAuthorizationIfNeededAndStart() {
        let typesToShare: Set = [HKObjectType.workoutType()]
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare,
                                         read: typesToRead) { success, _ in
            if success {
                DispatchQueue.main.async {
                    self.startWorkoutSession()
                }
            } else {
                print("실패")
            }
        }
    }
    
    private func startWorkoutSession() {
        guard session == nil, builder == nil else {
            return
        }
        
        let config = HKWorkoutConfiguration()
        config.activityType = .running
        config.locationType = .outdoor
        
        do {
            let workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            let workoutBuilder = workoutSession.associatedWorkoutBuilder()
            
            self.session = workoutSession
            self.builder = workoutBuilder
            
            workoutSession.delegate = self
            workoutBuilder.delegate = self
            
            workoutBuilder.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: config
            )
            
            let startDate = Date()
            workoutSession.startActivity(with: startDate)
            workoutBuilder.beginCollection(withStart: startDate) { _, _ in }
        } catch {
            print("에러:", error)
        }
    }
    
    func pause() {
        session?.pause()
    }
    
    func resume() {
        session?.resume()
    }
    
    func stop() {
        guard let s = session else { return }
        s.end()
        builder?.endCollection(withEnd: Date()) { success, _ in
            if success {
                self.builder?.finishWorkout { _, _ in
                    self.session = nil
                    self.builder = nil
                }
            }
        }
    }
    
    // 심박 업데이트 콜백
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
                        didCollectDataOf collectedTypes: Set<HKSampleType>) {
        
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate),
              collectedTypes.contains(hrType),
              let stats = workoutBuilder.statistics(for: hrType)
        else { return }
        
        if let bpm = stats.mostRecentQuantity()?.doubleValue(for: HKUnit(from: "count/min")) {
            DispatchQueue.main.async {
                self.heartRate = Int(bpm)
                self.sendHeartRateToPhone(bpm: bpm)
            }
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didFailWithError error: Error) {
        print("error:", error)
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState,
                        date: Date) {
        if toState == .ended {
            print("end")
        }
    }
    
    // iPhone으로 심박수 전달
    private func sendHeartRateToPhone(bpm: Double) {
        let wc = wcSession
        guard wc.activationState == .activated else { return }
        
        if wc.isReachable {
            wc.sendMessage(["bpm": bpm], replyHandler: nil) { error in
                print("error:", error.localizedDescription)
            }
        } else {
            do {
                try wc.updateApplicationContext(["bpm": bpm])
            } catch {
                print("error:", error.localizedDescription)
            }
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        
    }
    
}
