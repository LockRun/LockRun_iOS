//
//  WatchAppDelegate.swift
//  LockRunWatchApp Watch App
//
//  Created by 전준영 on 11/6/25.
//

import WatchKit
import WatchConnectivity

class WatchAppDelegate: NSObject, WKApplicationDelegate, WCSessionDelegate {
    
    let workoutManager = WorkoutManager.shared
    let session = WCSession.default
    
    func applicationDidFinishLaunching() {
        // 워치 앱이 완전히 켜졌을 때든
        // 백그라운드에서 깨웠을 때든
        // 항상 여기부터 불린다.
        print("⌚️ [WatchAppDelegate] launched / background wake")
        WKInterfaceDevice.current().play(.start)
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
            print(" WCSession activated in WatchAppDelegate")
        }
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let connectivity as WKWatchConnectivityRefreshBackgroundTask:
                // 도착한 userInfo 패킷들 처리
                if let userInfo = connectivity.userInfo as? [String: Any],
                   userInfo["wake"] as? Bool == true {
                    // 워치에서 즉시 Workout 시작 (UI가 없어도 백그라운드로 시작 가능)
                    workoutManager.start()
                }
                connectivity.setTaskCompletedWithSnapshot(false)
                
            case let appRefresh as WKApplicationRefreshBackgroundTask:
                appRefresh.setTaskCompletedWithSnapshot(false)
                
            case let snapshot as WKSnapshotRefreshBackgroundTask:
                snapshot.setTaskCompleted(restoredDefaultState: true,
                                          estimatedSnapshotExpiration: .distantFuture,
                                          userInfo: nil)
                
            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    // iPhone이 transferUserInfo(["wake": true]) 보냄 → 여기로 옴
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        print("📩 received userInfo:", userInfo)
        if userInfo["wake"] as? Bool == true {
            print("✅ wake received -> starting workout")
            workoutManager.start()
        }
    }
    
    // iPhone이 sendMessage(["action": "pause"/"resume"/"stop"]) 할 때는
    // 워치 앱이 foreground일 때만 가능.
    // 근데 어차피 이건 사용자가 이미 러닝 중일 때 UI에서 눌러서 일어난 동작이라,
    // 그 상황은 워치 앱이 살아있다고 가정 가능.
    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any]) {
        if let action = message["action"] as? String {
            switch action {
            case "pause": workoutManager.pause()
            case "resume": workoutManager.resume()
            case "stop": workoutManager.stop()
            default: break
            }
        }
    }
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if let error { print("WCSession activation error:", error.localizedDescription) }
    }
    
}
