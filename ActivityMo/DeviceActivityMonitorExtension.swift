//
//  DeviceActivityMonitorExtension.swift
//  ActivityMo
//
//  Created by 전준영 on 10/10/25.
//

import DeviceActivity
import ManagedSettings
import FamilyControls
import UserNotifications

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
    }
    
    // 4) 구간 시작 직전 경고
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        // 알림 예약
        sendLocalNotification(
            title: "곧 앱 잠금이 시작됩니다",
            body: "5분 뒤 집중 모드가 시작됩니다. 작업을 마무리하고 뛸 준비~!"
        )
    }
    
    // 5) 구간 종료 직전 경고
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        // 잠금 해제 안내
        sendLocalNotification(
            title: "곧 잠금이 해제됩니다",
            body: "5분 뒤 앱이 다시 열릴 예정입니다~!"
        )
    }
    
    // 6) 이벤트 임계 도달 직전 경고
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        // TODO: "남은 허용치 10% 이하" 같은 경고 토스트/알림(필요시)
    }
    
    func sendLocalNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // nil로 해야 즉시 발송함
        )
        UNUserNotificationCenter.current().add(request)
    }
    
}

extension ManagedSettingsStore.Name {
    static let studyLock = Self("studyLock")
}
