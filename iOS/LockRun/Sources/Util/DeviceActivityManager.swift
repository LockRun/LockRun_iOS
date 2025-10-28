//
//  DeviceActivityManager.swift
//  LockRun
//
//  Created by 전준영 on 10/18/25.
//

import Foundation
import DeviceActivity

enum DeviceActivityManager {
    static func startDailySchedule(
        name: String,
        start: DateComponents,
        end: DateComponents
    ) async throws {
        let center = DeviceActivityCenter()
        let schedule = DeviceActivitySchedule(
            intervalStart: start,
            intervalEnd: end,
            repeats: true,
            warningTime: DateComponents(minute: 5)
        )
        do {
            try center.startMonitoring(
                DeviceActivityName(name),
                during: schedule
            )
            
            print("✅ DeviceActivity startMonitoring 성공")
            print("   이름: \(name)")
            print("   시작: \(start)")
            print("   종료: \(end)")
        } catch {
            print("❌ DeviceActivity startMonitoring 실패")
            print("   이름: \(name)")
            print("   시작: \(start)")
            print("   종료: \(end)")
            print("   에러: \(error.localizedDescription)")
            throw error
        }
    }
    
    static func stopMonitoring(name: String) async throws {
        let center = DeviceActivityCenter()
        //        center.stopMonitoring([DeviceActivityName(name)])
        do {
            center.stopMonitoring([DeviceActivityName(name)])
            print("🛑 Monitoring 중지 성공: \(name)")
        } catch {
            print("❌ Monitoring 중지 실패: \(error.localizedDescription)")
            throw error
        }
    }
}
