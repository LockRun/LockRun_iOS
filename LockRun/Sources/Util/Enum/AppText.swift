//
//  AppText.swift
//  LockRun
//
//  Created by 전준영 on 10/12/25.
//

import Foundation

enum AppText {
    
    enum Onboarding: String{
        case title = "달리면 잠금해제,\n꾸준함이 나를 자유롭게 합니다"
        case subTitle = "그럼 달려 볼까요"
    }
    
    enum OnboardingPermission: String{
        case title = "락런 앱 이용을 위해\n권한 허용이 반드시 필요합니다."
        case subTitle = "락런을 사용하려면\n아래 순서에 맞게 권한을 꼭 허용을 해주셔야합니다!"
        case screenTimePermission = "스크린 타임 접근 허용"
        case subScreenTime = "내가 설정한 거리만큼 앱이 제어될 거예요."
        case walkingPermission = "걸음 정보 허용"
        case subWalking = "오늘의 걸음 정보로 차트를 보여줘요."
        case locationPermission = "위치 권한 허용"
        case subLocation = "실시간으로 거리를 그려주기 위해 필요해요."
        case alertPermission = "알림 허용"
        case subAlert = "앱이 제어되기 직전에 알려줘요."
        case cameraPermission = "카메라 허용(선택)"
        case subCamera = "인증샷을 위해 필요해요."
    }
}
