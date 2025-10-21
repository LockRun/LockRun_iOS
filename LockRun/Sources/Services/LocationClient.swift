//
//  LocationClient.swift
//  LockRun
//
//  Created by 전준영 on 10/20/25.
//

import Dependencies
import CoreLocation

struct LocationClient {
    var request: () async -> CLLocationCoordinate2D
    var resolvePlaceName: (CLLocationCoordinate2D) async -> String
}

// LocationClient.swift
private var delegateAssocKey: UInt8 = 0
private var managerAssocKey: UInt8 = 0

enum LocationClientKey: DependencyKey {
    static let liveValue = LocationClient(
        request: {
            await withCheckedContinuation { cont in
                Task { @MainActor in
                    let manager = CLLocationManager()
                    let delegate = LocationDelegate(manager: manager, continuation: cont)
                    manager.delegate = delegate
                    
                    // 강한 참조 유지(ARC 사용을 못 할 가능성이 보여서)
                    objc_setAssociatedObject(manager,
                                             &delegateAssocKey,
                                             delegate,
                                             .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    objc_setAssociatedObject(delegate,
                                             &managerAssocKey,
                                             manager,
                                             .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    manager.requestWhenInUseAuthorization()
                    manager.requestLocation()
                }
            }
        }, resolvePlaceName: { coord in
            let geocoder = CLGeocoder()
            let placemarks = try? await geocoder.reverseGeocodeLocation(.init(latitude: coord.latitude,
                                                                              longitude: coord.longitude))
            let p = placemarks?.first
            let name = [p?.locality, p?.subLocality].compactMap{$0}.joined(separator: " ")
            return name
        }
    )
    
}

extension DependencyValues {
    var locationClient: LocationClient {
        get { self[LocationClientKey.self] }
        set { self[LocationClientKey.self] = newValue }
    }
}


final class LocationDelegate: NSObject, CLLocationManagerDelegate {
    
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Never>?
    private var manager: CLLocationManager?
    
    init(manager: CLLocationManager,
         continuation: CheckedContinuation<CLLocationCoordinate2D, Never>) {
        self.manager = manager
        self.continuation = continuation
        super.init()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last?.coordinate {
            continuation?.resume(returning: loc)
            continuation = nil
        }
        self.manager = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        continuation?.resume(returning: CLLocationCoordinate2D(latitude: 37.5665,
                                                               longitude: 126.9780))
        continuation = nil
        self.manager = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        default:
            break
        }
    }
    
}

struct Coordinate: Equatable {
    var latitude: Double
    var longitude: Double
}

extension CLLocationCoordinate2D {
    init(_ c: Coordinate) {
        self.init(latitude: c.latitude, longitude: c.longitude)
    }
}
