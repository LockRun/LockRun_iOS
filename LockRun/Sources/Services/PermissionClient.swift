//
//  PermissionClient.swift
//  LockRun
//
//  Created by 전준영 on 11/4/25.
//

import Dependencies

struct PermissionClient {
    var requestHealthKit: @Sendable () async throws -> Bool
}

enum PermissionClientKey: DependencyKey {
    static let liveValue = PermissionClient(
        requestHealthKit: {
            try await PermissionManager().requestHealthKitAuthorization()
        }
    )
}

extension DependencyValues {
    var permissionClient: PermissionClient {
        get { self[PermissionClientKey.self] }
        set { self[PermissionClientKey.self] = newValue }
    }
}
