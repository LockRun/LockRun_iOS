//
//  LocationManager.swift
//  LockRun
//
//  Created by 전준영 on 10/10/25.
//

import SwiftUI
import CoreLocation

class LocationManager: NSObject,
                       ObservableObject,
                       CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager() //위치 추적 가능한 Manager
    @Published var authorizationStatus: CLAuthorizationStatus? //권한 상태 관리
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways: //위치 사용 권한 항상 허용되어 있음
            authorizationStatus = .authorizedAlways
            break
            
        case .authorizedWhenInUse: //위치 사용 권한 앱 사용 시 허용되어 있음
            authorizationStatus = .authorizedWhenInUse
            locationManager.requestLocation()
            break
            
        case .denied: //위치 사용 권한 거부되어 있음
            authorizationStatus = .denied
            DispatchQueue.main.async { //앱 설정화면으로 화면 이동
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            break
            
        case .notDetermined, .restricted: //위치 사용 권한 대기 상태
            authorizationStatus = .notDetermined
            manager.requestWhenInUseAuthorization() //권한 요청 팝업창
            break
            
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        // Insert code to handle location updates
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
    
    func stopLocation() {
        locationManager.stopUpdatingLocation()
    }
    
}
