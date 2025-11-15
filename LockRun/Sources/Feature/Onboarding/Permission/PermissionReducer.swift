//
//  PermissionReducer.swift
//  LockRun
//
//  Created by 전준영 on 10/13/25.
//

import Foundation
import ComposableArchitecture

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
                            let granted = try await permissionClient.requestScreenTime()
                            await send(granted ? .stepGranted(1) : .stepDenied(1))
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
                    
                case 3:
                    return .run { send in
                        let granted = await permissionClient.requestLocation()
                        await send(granted ? .stepGranted(3) : .stepDenied(3))
                    }
                    
                case 4:
                    return .run { send in
                        let granted = await permissionClient.requestNotification()
                        await send(granted ? .stepGranted(4) : .stepDenied(4))
                    }
                    
                case 5:
                    return .run { send in
                        let granted = await permissionClient.requestCamera()
                        await send(granted ? .stepGranted(5) : .stepDenied(5))
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
