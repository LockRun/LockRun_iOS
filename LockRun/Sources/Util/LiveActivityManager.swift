//
//  LiveActivityManager.swift
//  LockRun
//
//  Created by 전준영 on 11/10/25.
//

import ActivityKit

final class LiveActivityManager {
    
    static let shared = LiveActivityManager()
    private init() {}

    private var current: Activity<RunningAttributes>?

    func start(goalDistance: Double,
               pace: String,
               elapsedTime: Int,
               distance: Double) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return
        }

        let attributes = RunningAttributes(goalDistance: goalDistance)
        let content = RunningAttributes.ContentState(
            elapsedTime: elapsedTime,
            pace: pace,
            distance: distance,
            isRunning: true
        )

        do {
            current = try Activity.request(attributes: attributes, contentState: content)
        } catch {
            print("Live Activity 생성 실패:", error.localizedDescription)
        }
    }

    func update(elapsedTime: Int,
                pace: String,
                distance: Double,
                isRunning: Bool = true) {
        Task {
            guard let current else { return }
            await current.update(using: .init(elapsedTime: elapsedTime,
                                              pace: pace,
                                              distance: distance,
                                              isRunning: isRunning))
        }
    }

    func stop(elapsedTime: Int,
              pace: String,
              distance: Double) {
        Task {
            for activity in Activity<RunningAttributes>.activities {
                await activity.end(
                    using: .init(elapsedTime: elapsedTime,
                                 pace: pace,
                                 distance: distance,
                                 isRunning: false),
                    dismissalPolicy: .immediate
                )
            }
        }
    }
    
}
