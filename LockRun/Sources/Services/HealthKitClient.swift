//
//  HealthKitClient.swift
//  LockRun
//
//  Created by 전준영 on 11/4/25.
//

import Dependencies
import HealthKit

struct HealthKitClient {
    var requestAuthorization: @Sendable () async throws -> Bool
    var startHeartRateStream: () -> AsyncStream<Double>
    var stopHeartRateStream: @Sendable () -> Void
}

final class HeartRateQueryBox {
    var query: HKAnchoredObjectQuery?
    var continuation: AsyncStream<Double>.Continuation?
}

enum HealthKitClientKey: DependencyKey {
    static let liveValue: HealthKitClient = {
        let store = HKHealthStore()
        let type = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let box = HeartRateQueryBox()

        let requestAuth: @Sendable () async throws -> Bool = {
            guard HKHealthStore.isHealthDataAvailable() else { return false }
            return try await withCheckedThrowingContinuation { cont in
                store.requestAuthorization(toShare: [], read: [type]) { ok, err in
                    if let err = err { cont.resume(throwing: err) }
                    else { cont.resume(returning: ok) }
                }
            }
        }

        let start: () -> AsyncStream<Double> = {
            AsyncStream<Double> { cont in
                box.continuation = cont
                box.query = HKAnchoredObjectQuery(type: type,
                                                  predicate: nil,
                                                  anchor: nil,
                                                  limit: HKObjectQueryNoLimit) { _, samples, _, _, _ in
                    Self.push(samples, to: box.continuation)
                }
                box.query?.updateHandler = { _, samples, _, _, _ in
                    Self.push(samples, to: box.continuation)
                }
                if let q = box.query { store.execute(q) }

                cont.onTermination = { _ in
                    if let q = box.query { store.stop(q) }
                    box.query = nil
                    box.continuation = nil
                }
            }
        }

        let stop: @Sendable () -> Void = {
            if let q = box.query { store.stop(q) }
            box.query = nil
            box.continuation?.finish()
            box.continuation = nil
        }

        return HealthKitClient(
            requestAuthorization: requestAuth,
            startHeartRateStream: start,
            stopHeartRateStream: stop
        )
    }()

    private static func push(_ samples: [HKSample]?, to cont: AsyncStream<Double>.Continuation?) {
        guard let samples = samples as? [HKQuantitySample],
              let last = samples.last else { return }
        let bpm = last.quantity.doubleValue(for: HKUnit(from: "count/min"))
        cont?.yield(bpm)
    }
}

extension DependencyValues {
    var healthKitClient: HealthKitClient {
        get { self[HealthKitClientKey.self] }
        set { self[HealthKitClientKey.self] = newValue }
    }
}
