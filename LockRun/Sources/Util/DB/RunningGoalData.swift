//
//  RunningGoalData.swift
//  LockRun
//
//  Created by 전준영 on 10/20/25.
//

import Foundation
import SwiftData

@Model
final class RunningGoalData {
    
    @Attribute(.unique) var id: UUID
    var title: String
    var distanceGoal: Int
    var startTime: Date
    var endTime: Date
    
    init(title: String,
         distanceGoal: Int,
         startTime: Date,
         endTime: Date) {
        self.id = UUID()
        self.title = title
        self.distanceGoal = distanceGoal
        self.startTime = startTime
        self.endTime = endTime
    }
    
}
