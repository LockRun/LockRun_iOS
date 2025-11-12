//
//  PauseRunningIntent.swift
//  LockRun
//
//  Created by 전준영 on 11/10/25.
//

import AppIntents

struct PauseRunningIntent: AppIntent {
    
    static var title: LocalizedStringResource = "러닝 일시정지"
    static var description = IntentDescription("현재 러닝 세션을 일시정지합니다.")
    
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .pauseRunningRequested, object: nil)
        return .result()
    }
}
