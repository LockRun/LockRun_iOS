//
//  DeviceReportHostView.swift
//  LockRun
//
//  Created by 전준영 on 11/9/25.
//

import SwiftUI
import DeviceActivity

/// 이 뷰가 렌더링되면 ActivityRe 리포트가 실제 실행되어 AppGroup에 데이터가 저장됨
struct DeviceReportHostView: View {
    private let context = DeviceActivityReport.Context("Total Activity")
    @State private var filter = DeviceActivityFilter(
        segment: .hourly(
            during: Calendar.current.dateInterval(of: .day, for: .now)!
        ),
        users: .all,
        devices: .init([.iPhone])
    )

    var body: some View {
        DeviceActivityReport(context, filter: filter)
            .frame(height: 1)
            .opacity(0.01)
            .accessibilityHidden(true)
            .onAppear {
                print("🔔 DeviceReportHostView appeared → ReportExtension 트리거")
            }
    }
}

