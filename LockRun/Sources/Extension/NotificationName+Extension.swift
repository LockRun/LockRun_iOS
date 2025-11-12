//
//  NotificationName+Extension.swift
//  LockRun
//
//  Created by 전준영 on 11/10/25.
//

import Foundation

extension Notification.Name {
    static let pauseRunningRequested = Notification.Name("pauseRunningRequested")
    static let resumeRunningRequested = Notification.Name("resumeRunningRequested")
}
