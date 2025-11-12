//
//  TotalActivityReport.swift
//  ActivityRe
//
//  Created by 전준영 on 10/10/25.
//

import DeviceActivity
import SwiftUI
import os

extension DeviceActivityReport.Context {
    static let totalActivity = Self("Total Activity")
}

struct TotalActivityReport: DeviceActivityReportScene {
    private let logger = Logger(subsystem: "com.lockRun.ActivityRe", category: "Report")

    let context: DeviceActivityReport.Context = .totalActivity
    let content: (ScreenTimeSummary) -> TotalActivityView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> ScreenTimeSummary {
        var hourBuckets: [Int: Double] = [:]
        var appDict: [String: Double] = [:]

        for await device in data {
            for await segment in device.activitySegments {
                let hour = Calendar.current.component(.hour, from: segment.dateInterval.start)
                hourBuckets[hour, default: 0] += segment.totalActivityDuration / 60.0

                for await category in segment.categories {
                    for await app in category.applications {
                        let name = app.application.localizedDisplayName ?? "Unknown"
                        appDict[name, default: 0] += app.totalActivityDuration / 60.0
                    }
                }
            }
        }

        let hourly = (0..<24).map { HourlyUsage(hour: $0, usageMinutes: hourBuckets[$0, default: 0]) }
        let topApps = appDict
            .map { AppUsage(appName: $0.key, usageMinutes: $0.value, changePercent: 0) }
            .sorted { $0.usageMinutes > $1.usageMinutes }
            .prefix(10)

        let summary = ScreenTimeSummary(hourly: hourly, topApps: Array(topApps))

        return summary
    }
}
