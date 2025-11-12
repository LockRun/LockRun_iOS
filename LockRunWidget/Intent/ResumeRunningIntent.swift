//
//  ResumeRunningIntent.swift
//  LockRun
//
//  Created by 전준영 on 11/10/25.
//

import AppIntents

struct ResumeRunningIntent: AppIntent {
    
    static var title: LocalizedStringResource = "러닝 재시작"
    static var description = IntentDescription("러닝 세션을 다시 시작합니다.")
    
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .resumeRunningRequested, object: nil)
        return .result()
    }
}
