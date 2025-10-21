//
//  DeviceActivityMonitorExtension.swift
//  ActivityMo
//
//  Created by 전준영 on 10/10/25.
//

import DeviceActivity
import ManagedSettings
import FamilyControls

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    let store = ManagedSettingsStore(named: .studyLock)
    
    // 1) 스케줄 구간이 시작될 때
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        guard let s = FamilyActivityStorage.load() else {
            return
        }
        
        store.shield.applications = Set(s.apps)
        store.shield.applicationCategories = .specific(Set(s.categories))
        store.shield.webDomains = Set(s.webDomains)
    }
    
    // 2) 스케줄 구간이 끝났을 때
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        store.shield.applications = []
        store.shield.applicationCategories = nil
        store.shield.webDomains = []
    }
    
    // 3) 이벤트 누적 사용량이 임계값(Threshold)에 도달했을 때
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        // TODO: 목표 거리 달성, 사용 제한 초과 등 트리거 → 로컬 알림/배지/요약 저장
    }
    
    // 4) 구간 시작 직전 경고
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        // TODO: "곧 러닝 집중 모드가 시작돼요" 알림 예약
    }
    
    // 5) 구간 종료 직전 경고
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        // TODO: "곧 제한이 풀립니다" 안내
    }
    
    // 6) 이벤트 임계 도달 직전 경고
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        // TODO: "남은 허용치 10% 이하" 같은 경고 토스트/알림
    }
}

extension ManagedSettingsStore.Name {
    static let studyLock = Self("studyLock")
}
