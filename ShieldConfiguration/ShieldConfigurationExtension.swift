//
//  ShieldConfigurationExtension.swift
//  ShieldConfiguration
//
//  Created by 전준영 on 10/24/25.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    //특정 앱 잠금 화면
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Customize the shield as needed for applications.
        let config = ShieldConfiguration(backgroundBlurStyle: .regular,
                            backgroundColor: .background,
                            icon: UIImage.logo,
                            title: .init(text: "오늘도 어제보다 강한 나를 만들어보자!",
                                         color: .white),
                            subtitle: .init(text: "지금은 집중 시간입니다. 러닝을 마치면 해제돼요.",
                                            color: .lightGray),
                            primaryButtonLabel: .init(text: "러닝 기록 확인", color: .white),
                            primaryButtonBackgroundColor: .darkGreen,
                            secondaryButtonLabel: .init(text: "앱닫기", color: .red))
        
        return config
    }
    
    //카테고리로 잠금 화면
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for applications shielded because of their category.
        ShieldConfiguration()
    }
    
    //특정 웹 사이트 잠금화면
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Customize the shield as needed for web domains.
        ShieldConfiguration()
    }
    
    //특정 웹 카테고리 사이트 잠금화면
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for web domains shielded because of their category.
        ShieldConfiguration()
    }
    
}
