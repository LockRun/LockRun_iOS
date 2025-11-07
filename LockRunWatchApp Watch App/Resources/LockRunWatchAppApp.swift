//
//  LockRunWatchAppApp.swift
//  LockRunWatchApp Watch App
//
//  Created by 전준영 on 11/5/25.
//

import SwiftUI
import WatchKit

@main
struct LockRunWatchApp_Watch_AppApp: App {
    
    @WKApplicationDelegateAdaptor(WatchAppDelegate.self) var appDelegate
    @StateObject var workoutManager = WorkoutManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutManager)
        }
    }
    
}
