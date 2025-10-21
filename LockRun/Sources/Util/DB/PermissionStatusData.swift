//
//  PermissionStatusData.swift
//  LockRun
//
//  Created by 전준영 on 10/15/25.
//

import Foundation
import SwiftData

@Model
final class PermissionStatusData {
    
    @Attribute(.unique) var id: String
    // 모든 권한 허용 완료 여부
    var isAllGranted: Bool
    // 마지막 업데이트 시각
    var updatedAt: Date
    
    init(isAllGranted: Bool = false) {
        self.id = "permission_status"
        self.isAllGranted = isAllGranted
        self.updatedAt = Date()
    }
    
}
