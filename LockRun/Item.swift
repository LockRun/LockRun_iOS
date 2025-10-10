//
//  Item.swift
//  LockRun
//
//  Created by 전준영 on 10/10/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
