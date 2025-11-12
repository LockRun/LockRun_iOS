//
//  AnalyzeReducer.swift
//  LockRun
//
//  Created by 전준영 on 10/15/25.
//

import Foundation
import ComposableArchitecture

// MARK: - Models
struct RunningSessionAppUsage: Identifiable, Equatable {
    let id = UUID()
    let appName: String
    let usageMinutes: Double
}

// MARK: - Analyze Reducer
@Reducer
struct Analyze: Reducer {
    
    @Dependency(\.deviceActivityClient) var deviceActivityClient   // ✅ 의존성 주입
    
    @ObservableState
    struct State: Equatable {
        var hourlyUsage: [HourlyUsage] = []              // 시간대별 총 스크린타임
        var topApps: [AppUsage] = []                     // 이번 주 많이 사용한 앱 Top10
        var duringRunApps: [RunningSessionAppUsage] = [] // 러닝 중 사용 앱
        var summaryLine1: String = "데이터를 불러오는 중..."
        var summaryLine2: String = ""
        var selectedHour: Int?
        var focusScore: Int = 0
        var isLoading: Bool = false                      // ✅ 로딩 상태 추가
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case _loaded(hourly: [HourlyUsage], top: [AppUsage])
        //        case _failedToLoad(Error)                        // ✅ 에러 핸들링
        case hourSelected(Int?)
        case lockRecommendedAppsTapped
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
                
                // ✅ onAppear → 실제 DeviceActivityClient 데이터 요청
            case .onAppear:
                state.isLoading = true
                state.summaryLine1 = "스크린타임 데이터를 불러오는 중..."
                state.summaryLine2 = ""
                
                return .run { send in
                    do {
                        let (hourly, top) = try await deviceActivityClient.fetchUsageData()
                        await send(._loaded(hourly: hourly, top: top))
                    } catch {
                        //                        await send(._failedToLoad(error))
                    }
                }
                
                // ✅ 데이터 로드 완료
            case let ._loaded(hourly, top):
                state.isLoading = false
                state.hourlyUsage = hourly
                state.topApps = top
                
                let totalMin = hourly.map(\.usageMinutes).reduce(0, +)
                let totalHour = totalMin / 60.0
                
                // 🔢 Focus Score 계산 (예시: 낮은 사용량일수록 높게)
                let normalizedScore = max(0, min(100, Int(100 - totalHour * 2)))
                state.focusScore = normalizedScore
                
                // 요약 문구
                state.summaryLine1 = "오늘 총 사용 \(String(format: "%.1fh", totalHour))"
                if let topApp = top.first {
                    state.summaryLine2 = "가장 많이 사용한 앱은 \(topApp.appName)이에요 📱"
                } else {
                    state.summaryLine2 = "데이터를 찾을 수 없어요."
                }
                
                return .none
                
                // ✅ 에러 발생 시
                //            case let ._failedToLoad(error):
                //                state.isLoading = false
                //                state.summaryLine1 = "데이터를 불러오지 못했어요."
                //                state.summaryLine2 = "\(error.localizedDescription)"
                //                print("❌ [AnalyzeReducer] 스크린타임 로드 실패: \(error)")
                //                return .none
                
                // ✅ 차트에서 시간 선택
            case let .hourSelected(hr):
                state.selectedHour = hr
                return .none
                
                // ✅ 러닝 중 자주 사용한 앱 잠금 버튼
            case .lockRecommendedAppsTapped:
                // TODO: FamilyActivityPicker 연결 → 상위 duringRunApps 기준으로 잠금 추천
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}
