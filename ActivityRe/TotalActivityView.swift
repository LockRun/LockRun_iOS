//
//  TotalActivityView.swift
//  ActivityRe
//
//  Created by 전준영 on 10/10/25.
//

import SwiftUI
import Charts

struct TotalActivityView: View {
    
    let summary: ScreenTimeSummary

    var body: some View {
//        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {

                // 상단 타이틀
                VStack(alignment: .leading, spacing: 4) {
                    Text("러닝 & 디지털 디톡스 리포트")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text("시간대별 사용 패턴과 가장 많이 쓴 앱을 한눈에")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal)
                
                Button {
                    print("??")
                } label: {
                    Image(systemName: "figure.run")
                        .foregroundStyle(.white)
                        .font(.system(size: 32))
                        .padding(32)
                        .shadow(radius: 8)
                }
                .padding(.bottom, 100)
                
                HourlyUsageChartView(hourlyUsage: summary.hourly)
                    .padding(.horizontal)

                TopAppsListView(apps: summary.topApps)
                    .padding(.horizontal)

                SummaryCardView(summary: summary)
                    .padding(.horizontal)

                Spacer(minLength: 40)
            }
            .padding(.top, 16)
//        }
//        .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - 시간대별 차트
struct HourlyUsageChartView: View {
    let hourlyUsage: [HourlyUsage]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("시간대별 스크린타임")
                .font(.headline)
                .foregroundColor(.white)

            Chart {
                ForEach(hourlyUsage) { item in
                    BarMark(
                        x: .value("시간", item.hour),
                        y: .value("분", item.usageMinutes)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    .cornerRadius(3)
                }
            }
            .chartXAxis {
                AxisMarks(values: Array(stride(from: 0, to: 24, by: 3))) { value in
                    AxisValueLabel {
                        if let hour = value.as(Int.self) {
                            Text("\(hour)시")
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 220)
            .background(
                RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
    }
}

// MARK: - Top Apps
struct TopAppsListView: View {
    let apps: [AppUsage]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("이번 주 많이 사용한 앱 Top 10")
                .font(.headline)
                .foregroundColor(.white)

            VStack(spacing: 8) {
                ForEach(Array(apps.prefix(10).enumerated()), id: \.1.id) { idx, app in
                    HStack(spacing: 12) {
                        Text("\(idx + 1)")
                            .font(.subheadline.bold())
                            .frame(width: 26, height: 26)
                            .background(Circle().fill(Color.white.opacity(0.15)))
                            .foregroundColor(.white)

                        Text(app.appName)
                            .foregroundColor(.white)

                        Spacer()

                        Text(String(format: "%.0f분", app.usageMinutes))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.vertical, 6)

                    if idx != apps.count - 1 {
                        Divider().background(Color.white.opacity(0.08))
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.3)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
    }
}

struct SummaryCardView: View {
    let summary: ScreenTimeSummary

    private var totalHour: Double {
        summary.hourly.map(\.usageMinutes).reduce(0, +) / 60.0
    }

    private var topAppName: String {
        summary.topApps.first?.appName ?? "데이터 없음"
    }

    private var focusScore: Int {
        max(0, min(100, Int(100 - totalHour * 2)))
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("이번 주 요약")
                    .foregroundColor(.white)
                    .font(.headline)
                Text("총 사용 시간 \(String(format: "%.1fh", totalHour))")
                    .foregroundColor(.white.opacity(0.85))
                Text("가장 많이 사용한 앱: \(topAppName)")
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            VStack(spacing: 6) {
                Text("Focus")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                Text("\(focusScore)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.green)
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.35)))
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.4)))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
}

#Preview {
    TotalActivityView(
        summary: ScreenTimeSummary(
            hourly: (0..<24).map { .init(hour: $0, usageMinutes: Double.random(in: 10...60)) },
            topApps: [
                .init(appName: "YouTube", usageMinutes: 120, changePercent: 0),
                .init(appName: "Instagram", usageMinutes: 80, changePercent: 0),
                .init(appName: "KakaoTalk", usageMinutes: 60, changePercent: 0),
                .init(appName: "Safari", usageMinutes: 40, changePercent: 0),
                .init(appName: "TikTok", usageMinutes: 35, changePercent: 0)
            ]
        )
    )
}
