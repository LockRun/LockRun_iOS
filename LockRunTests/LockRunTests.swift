//
//  LockRunTests.swift
//  LockRunTests
//
//  Created by 전준영 on 10/10/25.
//

import Testing
@testable import LockRun
import ComposableArchitecture
import Foundation

extension Tag {
    @Tag static var timeLogic: Self // 시간 관련 로직
    @Tag static var uiCritical: Self // UI관련 로직
    @Tag static var performance: Self // 성능 측정용
}

@Suite(.tags(.timeLogic))
struct RemainingTimeTests {

    @Suite(.timeLimit(.minutes(1)))
    struct TimeCalculation {
        
        @Test("러닝 시간 누적 테스트", .tags(.uiCritical))
        func runningTimeAccumulatesProperly() async throws {
            let clock = TestClock()
            let store = await TestStore(
                initialState: Home.State(
                    runningGoal: .init(
                        title: "테스트 목표",
                        distanceGoal: 5,
                        startTime: .now,
                        endTime: .now.addingTimeInterval(10)
                    )
                ),
                reducer: { Home() }
            ) {
                $0.continuousClock = clock
            }

            // 러닝 시작
            await store.send(.startRunning) {
                $0.runningState = .running
                $0.elapsedTime = 0
                $0.timeText = "00:00:00"
            }
            await store.receive(.notifyTabbarHide(true))
            // 3초 경과
            for expect in 1...3 {
                await clock.advance(by: .seconds(1))
                let formatted = String(format: "00:00:%02d", expect)
                await store.receive(.updateElapsedTime) {
                    $0.elapsedTime = TimeInterval(expect)
                    $0.timeText = formatted
                }
            }
            // 일시정지
            await store.send(.pauseRunning) {
                $0.runningState = .paused
            }
            await store.receive(.stopTimer)
            // 다시 시작
            await store.send(.resumeRunning) {
                $0.runningState = .running
            }
            
            // 5초 더 경과 → 총 8초
            for expect in 4...8 {
                await clock.advance(by: .seconds(1))
                let formatted = String(format: "00:00:%02d", expect)
                await store.receive(.updateElapsedTime) {
                    $0.elapsedTime = TimeInterval(expect)
                    $0.timeText = formatted
                }
            }
            await #expect(store.state.timeText == "00:00:08")

            // 정지
            await store.send(.stopRunning) {
                $0.runningState = .idle
                $0.elapsedTime = 0
                $0.timeText = "00:00:08"
            }
            
            await store.receive(.stopTimer)
            await store.receive(.notifyTabbarHide(false))
            await clock.advance(by: .seconds(1))
            await store.finish(timeout: .seconds(2))
        }
    }
    
}
