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
    var start: () -> AsyncStream<CLLocationCoordinate2D>
}

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
        }, start: {
            AsyncStream { continuation in
                Task { @MainActor in
                    DispatchQueue.global().async {
                        guard CLLocationManager.locationServicesEnabled() else {
                            return
                        }
                    }
                    let holder = LocationStreamHolder(continuation: continuation)
                    _locationHolders.append(holder)
                    holder.start()
                    
                    continuation.onTermination = { _ in
                        Task { @MainActor in
                            holder.stop()
                            if let idx = _locationHolders.firstIndex(where: { $0 === holder }) {
                                _locationHolders.remove(at: idx)
                            }
                        }
                    }
                }
            }
        }
        
    )
    
    static let testValue = LocationClient(
        request: { .init(latitude: 37.5665, longitude: 126.9780) },
        resolvePlaceName: { _ in "MockLocation" },
        start: {
            AsyncStream { continuation in
                // 위치 스트림 모의 종료
                continuation.finish()
            }
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

private var _locationHolders: [LocationStreamHolder] = []

final class LocationStreamHolder: NSObject, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    let continuation: AsyncStream<CLLocationCoordinate2D>.Continuation
    
    init(continuation: AsyncStream<CLLocationCoordinate2D>.Continuation) {
        self.continuation = continuation
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.delegate = self
    }
    
    func start() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func stop() {
        manager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("auth changed:", manager.authorizationStatus.rawValue)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let c = locations.last?.coordinate {
            continuation.yield(c)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location error:", error.localizedDescription)
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

extension Coordinate {
    var clLocationCoordinate2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension Array where Element == Coordinate {
    var totalDistanceInKm: Double {
        guard count > 1 else { return 0 }
        var distance: CLLocationDistance = 0
        for i in 1..<count {
            let start = CLLocation(latitude: self[i-1].latitude,
                                   longitude: self[i-1].longitude)
            let end = CLLocation(latitude: self[i].latitude,
                                   longitude: self[i].longitude)
            distance += end.distance(from: start)
        }
        return distance / 1000.0
    }
}
