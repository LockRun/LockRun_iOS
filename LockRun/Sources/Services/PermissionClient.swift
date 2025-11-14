//
//  PermissionClient.swift
//  LockRun
//
//  Created by 전준영 on 11/4/25.
//

import Dependencies

struct PermissionClient {
    var requestScreenTime: @Sendable () async throws -> Bool
    var requestHealthKit: @Sendable () async throws -> Bool
    var requestLocation: @Sendable () async -> Bool
    var requestNotification: @Sendable () async -> Bool
    var requestCamera: @Sendable () async -> Bool
}

enum PermissionClientKey: DependencyKey {
    static let liveValue = PermissionClient(
        requestScreenTime: {
            try await PermissionManager().requestScreenTimeAuthorization()
        }, requestHealthKit: {
            try await PermissionManager().requestHealthKitAuthorization()
        }, requestLocation: {
            await PermissionManager().requestLocationAuthorization()
        }, requestNotification: {
            await PermissionManager().requestNotificationAuthorization()
        }, requestCamera: {
            await PermissionManager().requestCameraAuthorization()
        }
    )
}

extension DependencyValues {
    var permissionClient: PermissionClient {
        get { self[PermissionClientKey.self] }
        set { self[PermissionClientKey.self] = newValue }
    }
}
