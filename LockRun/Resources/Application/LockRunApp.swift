//
//  LockRunApp.swift
//  LockRun
//
//  Created by 전준영 on 10/10/25.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

@main
struct LockRunApp: App {
    
    var sharedModelContainer = SwiftDataDBManager.shared.container
    @AppStorage("isOnboarded") private var isOnboarded = false
    
    var body: some Scene {
        
        WindowGroup {
            Group {
                if isOnboarded {
                    TabbarContainerView(store: Store(initialState: Tabbar.State()) {
                        Tabbar()
                    })
                    
                } else {
                    OnboardingView(store: Store(initialState: Onboarding.State()) {
                        Onboarding()
                    })
                }
            }
            .onOpenURL { url in
                if url.scheme == "lockrun", url.host == "running-stats" {
                    // TODO: 러닝 기록 화면으로 이동
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
