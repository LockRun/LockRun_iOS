//
//  ScreenTimeActivityReport.swift
//  ActivityRe
//
//  Created by 전준영 on 11/9/25.
//

import Foundation

struct HourlyUsage: Identifiable, Codable, Equatable {
    var id = UUID()
    let hour: Int
    let usageMinutes: Double
}

struct AppUsage: Identifiable, Codable, Equatable {
    var id = UUID()
    let appName: String
    let usageMinutes: Double
    let changePercent: Double
}

struct ScreenTimeSummary: Codable {
    let hourly: [HourlyUsage]
    let topApps: [AppUsage]
}
