//
//  WatchSessionManager.swift
//  LockRun
//
//  Created by 전준영 on 11/5/25.
//

import Foundation
import WatchConnectivity

final class WatchSessionManager: NSObject, WCSessionDelegate {// 워치랑 아이폰이랑 데이터 공유하려면 WCSessionDelegate사용
    
    static let shared = WatchSessionManager()
    private var session: WCSession
    
    private var streamContinuation: AsyncStream<Double>.Continuation?
    private var stream: AsyncStream<Double>!

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }

        // 스트림을 앱 생명주기 동안 1회만 생성
        stream = AsyncStream { continuation in
            self.streamContinuation = continuation
        }
    }
    
    // MARK: - 퍼머넌트 스트림 반환
    func startHeartRateStream() -> AsyncStream<Double> {
        return stream
    }
    
    func sendAction(_ action: String) {
        guard session.activationState == .activated else { return }
        if session.isReachable {
            session.sendMessage(["action": action], replyHandler: nil, errorHandler: nil)
            print("📤 Sent action to Watch:", action)
        }
    }
    
    func wakeWatchApp() {
        guard session.activationState == .activated else { return }
        session.transferUserInfo(["wake": true])
        print("Sent wake request to Watch app (transferUserInfo)")
    }

    // MARK: - 수신
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        if let bpm = userInfo["bpm"] as? Double {
            streamContinuation?.yield(bpm)
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let bpm = applicationContext["bpm"] as? Double {
            streamContinuation?.yield(bpm)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let bpm = message["bpm"] as? Double {
            streamContinuation?.yield(bpm)
        }
    }
    
    // MARK: - Delegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    
}
