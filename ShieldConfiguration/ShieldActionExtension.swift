//
//  ShieldActionExtension.swift
//  ShieldConfiguration
//
//  Created by 전준영 on 10/24/25.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldActionExtension: ShieldActionDelegate {
    override func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        switch action {
        case .primaryButtonPressed:
            completionHandler(.defer) // 시스템이 처리 대신 앱에게 위임
            
        case .secondaryButtonPressed:
            completionHandler(.close) // 앱 닫기 같은 기본 동작
            
        default:
            completionHandler(.none)
        }
    }
}
