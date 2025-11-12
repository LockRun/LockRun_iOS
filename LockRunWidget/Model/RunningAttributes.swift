//
//  RunningAttributes.swift
//  LockRun
//
//  Created by 전준영 on 11/10/25.
//

import Foundation
import ActivityKit

struct RunningAttributes: ActivityAttributes {
    
    public struct ContentState: Codable, Hashable {
        var elapsedTime: Int
        var pace: String
        var distance: Double
        var isRunning: Bool
    }
    
    var goalDistance: Double
    
}
