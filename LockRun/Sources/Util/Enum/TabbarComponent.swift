//
//  TabbarComponent.swift
//  LockRun
//
//  Created by 전준영 on 10/15/25.
//

import Foundation

enum TabComponent: Int, CaseIterable {
    case home, analyze, profile
    
    var icon: String {
        switch self {
        case .home:
            return "house"
            
        case .analyze:
            return "chart.bar"
            
        case .profile:
            return "person"
        }
    }
}
