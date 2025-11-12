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
        } catch {
            print("에러: \(error.localizedDescription)")
            throw error
        }
    }
    
    static func stopMonitoring(name: String) async throws {
        let center = DeviceActivityCenter()
        
        do {
            center.stopMonitoring([DeviceActivityName(name)])
        } catch {
            print("에러: \(error.localizedDescription)")
            throw error
        }
    }
}
