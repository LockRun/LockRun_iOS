//
//  PedometerClient.swift
//  LockRun
//
//  Created by 전준영 on 11/7/25.
//

import Dependencies
import CoreMotion

struct PedometerData: Equatable {
    var pace: Double? // 페이스
    var cadence: Double? //케이던스
    var distance: Double?
    var steps: Int?
}

struct PedometerClient {
    var requestAuthorization: @Sendable () async throws -> Bool
    var startPedometerUpdates: () -> AsyncStream<PedometerData>
    var stopPedometerUpdates: @Sendable () -> Void
}

final class PedometerBox {
    var pedometer: CMPedometer?
    var continuation: AsyncStream<PedometerData>.Continuation?
}

enum PedometerClientKey: DependencyKey {
    static let liveValue: PedometerClient = {
        let box = PedometerBox()

        // MARK: - 권한 요청
        let requestAuth: @Sendable () async throws -> Bool = {
            guard CMMotionActivityManager.isActivityAvailable() else { return false }

            let status = CMMotionActivityManager.authorizationStatus()
            if status == .authorized { return true }
            if status == .denied || status == .restricted { return false }

            // 아직 결정 안된 경우 → 요청 발생
            return await withCheckedContinuation { continuation in
                let manager = CMMotionActivityManager()
                manager.startActivityUpdates(to: .main) { _ in
                    continuation.resume(returning: CMMotionActivityManager.authorizationStatus() == .authorized)
                    manager.stopActivityUpdates()
                }
            }
        }

        // MARK: - 실시간 스트림 시작
        let start: () -> AsyncStream<PedometerData> = {
            AsyncStream { cont in
                let pedometer = CMPedometer()
                box.pedometer = pedometer
                box.continuation = cont

                pedometer.startUpdates(from: Date()) { data, error in
                    guard let data, error == nil else { return }

                    let value = PedometerData(
                        pace: data.currentPace?.doubleValue,
                        cadence: data.currentCadence?.doubleValue,
                        distance: data.distance?.doubleValue,
                        steps: data.numberOfSteps.intValue
                    )

                    cont.yield(value)
                }

                cont.onTermination = { _ in
                    pedometer.stopUpdates()
                    box.pedometer = nil
                    box.continuation = nil
                }
            }
        }

        // MARK: - 스트림 중단
        let stop: @Sendable () -> Void = {
            box.pedometer?.stopUpdates()
            box.pedometer = nil
            box.continuation?.finish()
            box.continuation = nil
        }

        return PedometerClient(
            requestAuthorization: requestAuth,
            startPedometerUpdates: start,
            stopPedometerUpdates: stop
        )
    }()
    
}

extension DependencyValues {
    var pedometerClient: PedometerClient {
        get { self[PedometerClientKey.self] }
        set { self[PedometerClientKey.self] = newValue }
    }
}
