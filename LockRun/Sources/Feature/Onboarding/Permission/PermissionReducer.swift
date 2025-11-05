//
//  PermissionReducer.swift
//  LockRun
//
//  Created by 전준영 on 10/13/25.
//

import SwiftUI
import FamilyControls
import ComposableArchitecture
import CoreMotion
import AVFoundation

enum PermissionStatus: Equatable {
    case notRequested
    case granted
    case denied
}

@Reducer
struct Permission: Reducer {
    
    @ObservableState
    struct State: Equatable {
        var steps: [PermissionStatus] = Array(repeating: .notRequested,
                                              count: 5)
        var currentStep: Int = 1
    }
    
    enum Action {
        case requestStep(Int)
        case stepGranted(Int)
        case stepDenied(Int)
        case nextStep
    }
    
    @Dependency(\.permissionClient) var permissionClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .requestStep(let index):
                switch index {
                case 1:
                    return .run { send in
                        do {
                            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                            await send(.stepGranted(1))
                        } catch {
                            await send(.stepDenied(1))
                        }
                    }
                    
                case 2:
                    return .run { send in
                        do {
                            let granted = try await permissionClient.requestHealthKit()
                            await send(granted ? .stepGranted(2) : .stepDenied(2))
                        } catch {
                            await send(.stepDenied(2))
                        }
                    }

//                    return .run { send in
//                        //모션이 가능한 폰인지 확인(시뮬은 전부 안됨, iPad도 안됨)
//                        guard CMMotionActivityManager.isActivityAvailable() else {
//                            await send(.stepDenied(2))
//                            return
//                        }
//                        
//                        let manager = CMMotionActivityManager()
//                        
//                        let status = await withCheckedContinuation { continuation in
//                            manager.startActivityUpdates(to: .main) { _ in
//                                continuation.resume(returning: CMMotionActivityManager.authorizationStatus())
//                                manager.stopActivityUpdates()
//                            }
//                        }
//                        
//                        await send(status == .authorized ? .stepGranted(2) : .stepDenied(2))
//                    }
                    
                case 3:
                    return .run { send in
                        let manager = CLLocationManager()
                        
                        switch manager.authorizationStatus {
                        case .authorizedAlways, .authorizedWhenInUse:
                            await send(.stepGranted(3))
                            
                        case .denied, .restricted:
                            await send(.stepDenied(3))
                            
                        case .notDetermined:
                            manager.requestWhenInUseAuthorization()
                            try? await Task.sleep(nanoseconds: 500_000_000)
                            let newStatus = manager.authorizationStatus
                            if newStatus == .authorizedAlways || newStatus == .authorizedWhenInUse {
                                await send(.stepGranted(3))
                            } else {
                                await send(.stepDenied(3))
                            }
                            
                        default:
                            await send(.stepDenied(3))
                        }
                    }
                    
                case 4:
                    return .run { send in
                        let center = UNUserNotificationCenter.current()
                        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                        if granted {
                            await send(.stepGranted(4))
                        } else {
                            await send(.stepDenied(4))
                        }
                    }
                    
                case 5:
                    return .run { send in
                        let granted = await AVCaptureDevice.requestAccess(for: .video)
                        if granted {
                            await send(.stepGranted(5))
                        } else {
                            await send(.stepDenied(5))
                        }
                        await send(.nextStep)
                    }
                    
                default:
                    return .none
                }
                
            case .stepGranted(let index):
                state.steps[index-1] = .granted
                if index < 6 {
                    state.currentStep = index + 1
                }
                return .none
                
            case .stepDenied(let index):
                state.steps[index-1] = .denied
                if index < 6 {
                    state.currentStep = index + 1
                }
                return .none
                
            case .nextStep:
                if state.currentStep < 6 {
                    state.currentStep += 1
                } else if state.currentStep == 6 {
                    UserDefaults.standard.set(true, forKey: "isOnboarded")
                }
                return .none
            }
        }
    }
    
}

extension Permission.State {
    var currentButtonTitle: ButtonTitle {
        switch currentStep {
        case 1: return .screenTime
        case 2: return .health
        case 3: return .location
        case 4: return .alert
        case 5: return .camera
        case 6: return .start
        default: return .permission
        }
    }
}
