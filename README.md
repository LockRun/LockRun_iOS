![iOS 18.0](https://img.shields.io/badge/iOS-18.0-lightgrey?style=flat&color=181717)
[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-F05138.svg?style=flat&color=F05138)](https://swift.org/download/)
[![Xcode 16.4](https://img.shields.io/badge/Xcode-16.4-147EFB.svg?style=flat&color=147EFB)](https://apps.apple.com/kr/app/xcode/id497799835?mt=12)

# 🚀 락런(LockRun)

<img width="192" height="187" alt="스크린샷 2025-11-13 오후 1 48 32" src="https://github.com/user-attachments/assets/376c4d9f-b6f0-41a6-a11e-d1e5ea3be560" width="180"/>

## 프로젝트 소개
**락런(LockRun)** 은
“달리면 잠금 해제되는 스마트폰 자기 통제 앱”으로,
러닝 목표(거리·시간)를 달성해야만 특정 앱의 사용이 잠금 해제되는 **Screen Time API 기반 디지털 디톡스 앱**입니다.
운동 습관 형성과 스마트폰 의존도 감소를 동시에 이끌어내기 위해 설계되었습니다.

- **인원** : iOS 1명, Android 1명
- **진행 기간**
    - **기획** : 2025.10.04 ~ 2025.10.10
    - **개발** : 2025.10.11 ~ 2025.11.09
- **Deployment Target** : iOS 18.0
- **개발 환경** : Swift 6.0, Xcode 16.4

---

# 🛠️ 기술 스택

### **iOS**
SwiftUI · TCA · SwiftData · Dependencies · ScreenTime API(DeviceActivityMonitor · DeviceActivityReport · ShieldActionDelegate · ManagedSettingsStore)
App Group · CoreLocation · MapKit · WeatherKit · HealthKit · WatchKit · WCSession · CoreMotion
Charts · Lottie · ActivityKit(Live Activities) · Testing(단위 테스트)

---

# 📱 주요 화면

| 메인 화면 | 러닝 중 화면 | 러닝 결과 화면 | 스크린타임 차트 |
|---------------|---------------|---------------|---------------|
| <img src="https://github.com/user-attachments/assets/9adc0478-e63d-4cf9-8d71-4c13d0abea67" width="200"> | <img src="https://github.com/user-attachments/assets/2f7d1964-c5ba-4ab3-9a6a-5372435eed57" width="200">| <img src="https://github.com/user-attachments/assets/90a6caee-eddb-4060-b146-4db88668c11d" width="200"> | <img src="https://github.com/user-attachments/assets/5651eef0-b82e-4479-a0a3-429146f7398d" width="200"> |


---

# 🔑 주요 기능 및 상세 설명
<img width="2000" height="850" src="https://github.com/user-attachments/assets/2a4a2456-13de-4844-85e3-a6d97329116d" />


## 1) **Screen Time API 기반 앱 잠금/해제(Extension, AppGroup)**
- FamilyControls를 사용해 사용자가 직접 차단할 앱을 선택 → 선택한 앱들의 아이콘을 UI에 함께 표시
- DeviceActivityMonitor를 활용해 사용자가 설정한 시간대에 자동으로 잠금 스케줄을 등록
- ManagedSettingsStore를 통해 선택된 앱에 차단(Shield)을 적용
- 러닝 목표를 달성하면 잠금이 자동으로 해제되는 구조(매일 반복)
- ShieldActionDelegate를 적용한 차단 화면 UI 커스텀
- DeviceActivityReport를 기반으로 앱 사용량을 분석하여, 러닝 시간대에 특히 많이 사용하는 앱을 기준으로 “차단 추천 앱”을 제공

→ **App Group + UserDefaults** 기반으로 Main App ↔ Extension 간 데이터를 안정적으로 공유하도록 설계

---

## 2) **러닝 목표 설정 및 자동 잠금 해제**
- 시간/거리 기반 목표 설정  
- CoreLocation 기반 실시간 위치 추적  
- 설정한 목표 도달 시 자동 잠금 해제  
- AsyncStream 기반 실시간 이벤트 스트림 처리  
  - 위치 업데이트 스트림  
  - 러닝 타이머 스트림  
  - 심박수 스트림  
  - 목표 달성 감지 스트림  

---

## 3) **러닝 진행 상태 시각화 (Live Activities)**
- ActivityKit 기반 러닝 정보 실시간 표시
- Dynamic Island & Lock Screen에 페이스/거리/시간/심박수 표시

---

## 4) **지도 기반 러닝 경로 표시**
- MapKit + _MapKit_SwiftUI
- MKPolyline으로 이동 경로 시각화
- 러닝 시작 시 **Lottie 카운트다운 애니메이션** 적용
- (CoreMotion 사용) CMPedometer 기반 페이스/거리/케이던스 계산
  
---

## 5) **HealthKit + watchOS 연동**
- HKWorkoutSession 기반 심박수 측정
- WCSession으로 iPhone ↔ Watch 실시간 심장박동수 전송

---

## 6) **WeatherKit 기반 날씨 정보 표시**
- 현재 기온, 강수 확률, 날씨 아이콘 표시
- GPS 기반 날씨 업데이트

---

## 7) **SwiftData 기반 러닝 기록 저장**
- 총 거리, 시간, 날짜 저장
- SwiftData Model을 통한 러닝 히스토리 관리

---

## 8) **스크린타임 앱 사용량 차트**
- DeviceActivityReportExtension 활용
- 시간대별 앱 사용량 그래프 출력(Charts)
- 러닝 시간대에 많이 사용하는 앱을 분석하여 앱 차단 추천

---

## 9) **프로필 & 캘린더**
- 커스텀 달력으로 월별 러닝 기록 시각화
- 프로필 편집 가능

---

# 🏗️ 아키텍처

## **TCA 기반 아키텍처**
락런은 실시간 스트림 데이터가 많고 기능 간 상태 의존도가 높아 **TCA**를 채택했습니다.

- Reducer 단위별로 분리
- 명확한 Action → Reducer → State 구조
- Dependencies로 Side Effect 분리
- 테스트 가능한 구조
- 스코프 확장으로 화면 간 액션 체계적 관리

---

# 🐞 트러블슈팅

## 1. ScreenTime Extension(모니터링) 로그 확인 불가 문제
### 문제
ScreenTime 관련 기능(DeviceActivityMonitorExtension)은 메인 앱과 완전히 독립된 Extension으로 실행되기 때문에,
실기기 연결 후 print, log 를 출력해도 Xcode 콘솔에서 로그를 확인할 수 없었다.

즉, 값이 제대로 들어오는지 모니터링 로직이 정상 실행되는지 Shield/Monitor 스케줄이 실제로 적용되는지 전혀 파악할 수 없는 상태였다.

### 원인
메인 앱(Target: App)을 선택하면 메인 앱에서 발생하는 로그만 출력되며,
모니터링 Extension(Target: DeviceActivityMonitorExtension)은 별도의 프로세스로 동작한다.

즉, 메인 타깃으로 실행 → 모니터링 Extension 로그 확인 불가 Extension 타깃으로 실행 → 메인 앱 로그 확인 불가
서로 독립된 두 앱이기 때문에 하나의 콘솔에서 모두 볼 수 있는 방법이 원래 없음.

### 해결 과정
#### ✔ 1) 타깃을 Extension으로 전환하여 Extension 내부 로그 확인
Xcode 실행 타깃을 DeviceActivityMonitorExtension → My iPhone으로 설정하여 모니터링 Extension의 실행 로그는 확인할 수 있었다.

하지만 이 경우, 메인 앱이 실행되지 않기 때문에 메인 로직 앱 로고를 확인할 수 없다는 문제가 새로 생김.

#### ✔ 2) App Group 기반 “실시간 상태 출력” 뷰 제작

Extension과 App 간 통신은 App Group UserDefaults를 통해 가능하다는 점을 활용해,
Extension에서 특정 값이나 플래그를 UserDefaults(suiteName:)에 기록하도록 만들었다.
그리고 메인 앱에서는 이 값을 텍스트로 실시간 표시하는 간단한 Debug View를 구성했다.

예시 흐름:
1. Extension에서 이벤트 발생 → App Group에 write
2. 메인 앱의 Debug View에서 read → 즉시 UI 업데이트
3. 콘솔 로그가 없어도 Extension 동작을 실시간으로 확인 가능

### 결과

기존처럼 콘솔 로그를 의존하지 않고도 모니터링 Extension이 실제로 어떤 이벤트를 받았는지, 스케줄이 실행 중인지, 토큰이 정상으로 읽히는지
메인 앱 화면에서 바로 확인할 수 있었다.
두 프로세스의 로그를 모두 추적하기 어려운 Extension 구조의 한계를 App Group + Debug View 방식으로 해결함.

---

# 💬 회고

락런은 일반적인 러닝 앱을 넘어  
“타겟 거리 도달 → 앱 잠금 해제”라는 독특한 UX를 구현해야 했기 때문에  
**ScreenTime API · HealthKit · watchOS · ActivityKit · TCA** 등이 모두 결합된 복잡한 구조였습니다.
특히 Extension 간 통신, Live Activity 유지, 실시간 위치/심박수 스트림 등 다양한 복합 기술이 동시에 작동해야 했습니다.
그러나 기능 단위로 Reducer를 명확히 분리하고, App Group 기반 통신 구조를 설계하여 안정성과 확장성 모두 확보할 수 있었습니다.
향후에는 UI/UX 디자인을 더욱 정교하게 다듬고, 러닝 중 사용자 동기부여를 줄 수 있는 추가 기능(칭찬 시스템, 배지, 히스토리 통계 강화 등)을 확장해 나갈 예정입니다.
