//
//  AnalyzeView.swift
//  LockRun
//
//  Created by 전준영 on 10/15/25.
//

import SwiftUI
import ComposableArchitecture
import DeviceActivity
// 데모용 러닝 기록 (나중에 HealthKit/SwiftData로 대체)
private let demoRunningRecords: [RunningRecord] = (0..<36).map {
    RunningRecord(
        minute: $0,
        distance: Double($0) * 0.13,                 // 누적 km
        pace: 320 + Double.random(in: -25...25),     // 초/km (예: 5'20" = 320)
        heartRate: Int.random(in: 115...160),        // bpm
        cadence: Int.random(in: 150...180)           // spm
    )
}

struct AnalyzeView: View {
    
    @Bindable var store: StoreOf<Analyze>
    private let context = DeviceActivityReport.Context("Total Activity")
        @State private var filter = DeviceActivityFilter(
            segment: .hourly(
                during: Calendar.current.dateInterval(of: .day, for: .now)!
            ),
            users: .all,
            devices: .init([.iPhone])
        )
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    
                    DeviceActivityReport(context, filter: filter)
                        .frame(height: getScreenHeight()) // 예시: 화면 절반 높이
                    
                    
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
//        ScrollView(showsIndicators: false) {
//            VStack(alignment: .leading, spacing: 24) {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("러닝 & 디지털 디톡스 리포트")
//                        .font(.title2.bold())
//                        .foregroundColor(.white)
//                    Text("시간대별 사용 패턴과 가장 많이 쓴 앱을 한눈에")
//                        .font(.subheadline)
//                        .foregroundColor(.white.opacity(0.7))
//                }
//                .padding(.horizontal)
//                
//                DeviceActivityReport(context, filter: filter)
//                    .frame(minHeight: 350)
//                    .cornerRadius(16)
//                    .padding(.horizontal)
//
//
//                
//                // 5) 러닝 퍼포먼스 리포트 (새로 추가)
//                RunningPerformanceSectionView(
//                    records: demoRunningRecords,   // TODO: HealthKit/SwiftData 값으로 교체
//                    totalDistance: demoRunningRecords.last?.distance ?? 0,
//                    totalTime: (demoRunningRecords.last?.minute ?? 0),
//                    avgPace: averagePace(demoRunningRecords.map(\.pace)),
//                    avgHeart: Int(average(demoRunningRecords.map { Double($0.heartRate) })),
//                    avgCadence: Int(average(demoRunningRecords.map { Double($0.cadence) }))
//                )
//                .padding(.top, 8)
//                
//                Spacer(minLength: 40)
//            }
//            .padding(.top, 16)
//        }
//        .background(Color.black.ignoresSafeArea())
//        .task { store.send(.onAppear) }
    }
}

// MARK: - Helpers

private func average(_ values: [Double]) -> Double {
    guard !values.isEmpty else { return 0 }
    return values.reduce(0, +) / Double(values.count)
}

private func averagePace(_ secPerKmList: [Double]) -> Double {
    average(secPerKmList.filter { $0 > 0 })
}

#Preview {
    AnalyzeView(store: Store(initialState: Analyze.State()) { Analyze() })
}


//
//  HourlyUsageChartView.swift
//  LockRun
//
//  Created by Jun on 11/09/25.
//

import SwiftUI
import Charts

struct HourlyUsageChartView: View {
    let hourlyUsage: [HourlyUsage]
    let selectedHour: Int?
    let onSelect: (Int?) -> Void
    
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
                    .foregroundStyle(
                        (selectedHour == item.hour ? Color.blue.opacity(0.95) : Color.blue.opacity(0.6))
                            .gradient
                    )
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
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.3)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        // 대략적인 x 위치로 시간 추정(간단 터치 선택)
                        let width = UIScreen.main.bounds.width - 32 // padding 감안
                        let step = width / 24.0
                        let x = value.location.x - 16 // leading padding 보정
                        var hour = max(0, Int(x / step))
                        hour = min(23, hour)
                        if (0...23).contains(hour) {
                            onSelect(hour)
                        } else {
                            onSelect(nil)
                        }
                    }
            )
        }
    }
}

//
//  TopAppsListView.swift
//  LockRun
//
//  Created by Jun on 11/09/25.
//

import SwiftUI

struct TopAppsListView: View {
    let apps: [AppUsage]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("이번 주 많이 사용한 앱 Top 10")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                ForEach(Array(apps.enumerated()), id: \.1.id) { idx, app in
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
                        
                        Text(app.changePercent >= 0 ? "🔺\(Int(app.changePercent))%" : "🔻\(abs(Int(app.changePercent)))%")
                            .foregroundColor(app.changePercent >= 0 ? .red : .green)
                            .font(.caption)
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

//
//  DuringRunPieView.swift
//  LockRun
//
//  Created by Jun on 11/09/25.
//

import SwiftUI
import Charts

struct DuringRunPieView: View {
    let apps: [RunningSessionAppUsage]
    
    private var totalMinutes: Double {
        apps.map(\.usageMinutes).reduce(0, +)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("러닝 중 사용한 앱(집중 방해 요인)")
                .font(.headline)
                .foregroundColor(.white)
            
            ZStack {
                Chart {
                    ForEach(apps) { item in
                        SectorMark(
                            angle: .value("분", item.usageMinutes),
                            innerRadius: .ratio(0.6),
                            angularInset: 1.5
                        )
                        .foregroundStyle(by: .value("앱", item.appName))
                    }
                }
                .frame(height: 220)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.3)))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
                
                VStack(spacing: 4) {
                    Text("러닝 중 사용")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(Int(totalMinutes))분")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }
            }
            
            // 작은 레전드
            HStack(spacing: 12) {
                ForEach(apps.prefix(4)) { item in
                    HStack(spacing: 6) {
                        Circle().fill(color(for: item.appName)).frame(width: 10, height: 10)
                        Text(item.appName)
                            .foregroundColor(.white.opacity(0.9))
                            .font(.caption)
                        Text("\(Int(item.usageMinutes))분")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.caption2)
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }
    
    // 간단 색상 매핑(Charts 기본 팔레트로도 충분)
    private func color(for name: String) -> Color {
        let map: [String: Color] = [
            "Instagram": .pink, "YouTube": .red, "KakaoTalk": .yellow, "Safari": .blue,
            "TikTok": .purple, "Naver": .green, "Chrome": .gray
        ]
        return map[name, default: .cyan]
    }
}


//
//  SummaryCardView.swift
//  LockRun
//
//  Created by Jun on 11/09/25.
//

import SwiftUI

struct SummaryCardView: View {
    let line1: String
    let line2: String
    let focusScore: Int
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("📊 이번 주 효과 요약")
                    .foregroundColor(.white)
                    .font(.headline)
                Text(line1)
                    .foregroundColor(.white.opacity(0.85))
                Text(line2)
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

//
//  RunningPerformanceSectionView.swift
//  LockRun
//
//  Created by Jun on 11/09/25.
//

import SwiftUI
import Charts
import _DeviceActivity_SwiftUI

struct RunningRecord: Identifiable, Equatable {
    let id = UUID()
    let minute: Int     // 러닝 경과 시간 (분)
    let distance: Double// 누적 km
    let pace: Double    // 초/km
    let heartRate: Int  // bpm
    let cadence: Int    // spm
}

struct RunningPerformanceSectionView: View {
    let records: [RunningRecord]
    let totalDistance: Double
    let totalTime: Int
    let avgPace: Double
    let avgHeart: Int
    let avgCadence: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🏃‍♂️ 러닝 퍼포먼스 리포트")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            // 멀티 라인 그래프 (거리, 심박, 케이던스)
            Chart {
                ForEach(records) { rec in
                    LineMark(
                        x: .value("시간(분)", rec.minute),
                        y: .value("거리(km)", rec.distance)
                    )
                    .foregroundStyle(.green)
                    .interpolationMethod(.catmullRom)
                    
                    LineMark(
                        x: .value("시간(분)", rec.minute),
                        y: .value("심박수(bpm)", rec.heartRate)
                    )
                    .foregroundStyle(.red)
                    .interpolationMethod(.catmullRom)
                    
                    LineMark(
                        x: .value("시간(분)", rec.minute),
                        y: .value("케이던스(spm)", rec.cadence)
                    )
                    .foregroundStyle(.purple)
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { val in
                    AxisValueLabel {
                        if let m = val.as(Int.self), m % 5 == 0 {
                            Text("\(m)분")
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 220)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            
            // 컨셉 문구
            VStack(alignment: .leading, spacing: 4) {
                Text("러닝 중 심박 리듬과 케이던스는 집중력의 리듬이에요.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                Text("LockRun은 당신의 러닝 페이스가 일상의 집중 페이스로 이어지도록 도와줍니다.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal)
            
            // 요약 카드(거리/평균 페이스/평균 심박/평균 케이던스)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("거리")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text(String(format: "%.2f km", totalDistance))
                        .font(.title3.bold())
                        .foregroundColor(.green)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("평균 페이스")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text(formatPace(avgPace))
                        .font(.title3.bold())
                        .foregroundColor(.yellow)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("평균 심박수")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(avgHeart) bpm")
                        .font(.title3.bold())
                        .foregroundColor(.red)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("평균 케이던스")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(avgCadence) spm")
                        .font(.title3.bold())
                        .foregroundColor(.purple)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.4)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
            .padding(.horizontal)
        }
    }
    
    private func formatPace(_ secPerKm: Double) -> String {
        guard secPerKm.isFinite && secPerKm > 0 else { return "--'--\"" }
        let min = Int(secPerKm / 60)
        let sec = Int(secPerKm.truncatingRemainder(dividingBy: 60))
        return String(format: "%d'%02d\"", min, sec)
    }
}

//#Preview {
//    RunningPerformanceSectionView(
//        records: (0..<40).map {
//            RunningRecord(
//                minute: $0,
//                distance: Double($0) * 0.1,
//                pace: 320 + Double.random(in: -25...25),
//                heartRate: Int.random(in: 115...160),
//                cadence: Int.random(in: 150...180)
//            )
//        },
//        totalDistance: 4.2,
//        totalTime: 40,
//        avgPace: 318,
//        avgHeart: 138,
//        avgCadence: 168
//    )
//}

extension View {
    func getScreenWidth() -> CGFloat {
        guard let windowScene =
                UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return 0
        }

        return windowScene.screen.bounds.width
    }
    
    func getScreenHeight() -> CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return 0
        }
        
        return windowScene.screen.bounds.height
    }
}
