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
        TotalActivityReport { summary in
            TotalActivityView(summary: summary)
        }
    }
    
}
