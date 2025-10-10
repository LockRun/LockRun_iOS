//
//  ActivityRe.swift
//  ActivityRe
//
//  Created by 전준영 on 10/10/25.
//

import DeviceActivity
import SwiftUI

@main
struct ActivityRe: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Create a report for each DeviceActivityReport.Context that your app supports.
        TotalActivityReport { totalActivity in
            TotalActivityView(totalActivity: totalActivity)
        }
        // Add more reports here...
    }
}
