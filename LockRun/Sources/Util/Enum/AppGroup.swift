//
//  AppGroup.swift
//  LockRun
//
//  Created by 전준영 on 10/18/25.
//

import Foundation

enum AppGroup {
  static let suiteName = "group.com.lockRun.ScreenTimeGroup"
  static var defaults: UserDefaults { UserDefaults(suiteName: suiteName)! }
}
