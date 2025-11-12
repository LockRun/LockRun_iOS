//
//  DeviceActivityClient.swift
//  LockRun
//
//  Created by 전준영 on 11/9/25.
//

import Foundation
import Dependencies

struct DeviceActivityClient {
    var fetchUsageData: @Sendable () async throws -> ([HourlyUsage], [AppUsage])
}

extension DeviceActivityClient: DependencyKey {
    static let liveValue: Self = .init(
        fetchUsageData: {
            guard let data = AppGroup.defaults.data(forKey: "ScreenTimeSummary"),
                  let summary = try? JSONDecoder().decode(ScreenTimeSummary.self, from: data) else {
                return ([], [])
            }
            
            return (summary.hourly, summary.topApps)
        }
    )
}

extension DependencyValues {
    var deviceActivityClient: DeviceActivityClient {
        get { self[DeviceActivityClient.self] }
        set { self[DeviceActivityClient.self] = newValue }
    }
}
