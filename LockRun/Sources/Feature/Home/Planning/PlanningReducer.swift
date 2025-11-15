//
//  PlanningReducer.swift
//  LockRun
//
//  Created by 전준영 on 10/17/25.
//

import Foundation
import ComposableArchitecture
import FamilyControls
import ManagedSettings

@Reducer
struct Planning: Reducer {
    
    @ObservableState
    struct State: Equatable {
        var isEditMode: Bool?
        var selectedApps: FamilyActivitySelection = .init()
        var isFamilyPickerPresented: Bool = false
        var kmGoal: Int = 1
        var startTime: Date = Date().addingTimeInterval(60)
        var endTime: Date = Date().addingTimeInterval(3600)
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case toggleFamilyPicker(Bool)
        case saveButtonTapped
        case cancelButtonTapped
        case deleteButtonTapped
    }
    
    private let db = SwiftDataDBManager.shared
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .toggleFamilyPicker(let show):
                state.isFamilyPickerPresented = show
                return .none
                
            case .saveButtonTapped:
                FamilyActivityStorage.save(state.selectedApps)
                
                let startTime = state.startTime
                let endTime = state.endTime
                let distance = state.kmGoal
                let start = Calendar.current.dateComponents([.hour, .minute],
                                                            from: startTime)
                let end = Calendar.current.dateComponents([.hour, .minute],
                                                          from: endTime)
                if state.isEditMode == false {
                    return .run { send in
                        do {
                            try await DeviceActivityManager.startDailySchedule(name: "LockRunDailySchedule",
                                                                               start: start,
                                                                               end: end)
                            db.saveRunningGoal(
                                title: "러닝 목표",
                                distanceGoal: distance,
                                startTime: startTime,
                                endTime: endTime
                            )
                        }  catch {
                            print("실패: \(error.localizedDescription)")
                        }
                        
                        // 지금이 잠금시간이라면 즉시 차단
                        let now = Date()
                        if now >= startTime && now <= endTime {
                            if let s = FamilyActivityStorage.load() {
                                let store = ManagedSettingsStore(named: .studyLock)
                                store.shield.applications = Set(s.apps)
                                store.shield.applicationCategories = .specific(Set(s.categories))
                                store.shield.webDomains = Set(s.webDomains)
                            }
                        }
                        
                        await send(.cancelButtonTapped)
                    }
                } else {
                    return .run { send in
                        do {
                            try await DeviceActivityManager.stopMonitoring(name: "LockRunDailySchedule")
                            try await DeviceActivityManager.startDailySchedule(
                                name: "LockRunDailySchedule",
                                start: start,
                                end: end
                            )
                            
                            db.updateRunningGoal(
                                title: "러닝 목표",
                                distanceGoal: distance,
                                startTime: startTime,
                                endTime: endTime
                            )
                        }  catch {
                            print("실패: \(error.localizedDescription)")
                        }
                        
                        // 지금이 잠금시간이라면 즉시 차단
                        let now = Date()
                        if now >= startTime && now <= endTime {
                            if let s = FamilyActivityStorage.load() {
                                let store = ManagedSettingsStore(named: .studyLock)
                                store.shield.applications = Set(s.apps)
                                store.shield.applicationCategories = .specific(Set(s.categories))
                                store.shield.webDomains = Set(s.webDomains)
                            }
                        }
                        
                        await send(.cancelButtonTapped)
                    }
                }
                
            case .cancelButtonTapped:
                return .none
                
            case .deleteButtonTapped:
                
                return .run { send in
                    do {
                        try await DeviceActivityManager.stopMonitoring(name: "LockRunDailySchedule")
                        db.deleteRunningGoal()
                    } catch {
                        print("실패: \(error.localizedDescription)")
                    }
                    await send(.cancelButtonTapped)
                }
                
            default:
                return .none
            }
        }
    }
    
}
