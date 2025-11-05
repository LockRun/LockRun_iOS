//
//  WeatherClient.swift
//  LockRun
//
//  Created by 전준영 on 10/20/25.
//

import Dependencies
import CoreLocation
import WeatherKit

struct WeatherClient {
    var current: (CLLocationCoordinate2D) async throws -> WeatherSnapshot
}

enum WeatherClientKey: DependencyKey {
    static let liveValue = WeatherClient { coord in
        let service = WeatherService.shared
        
        // 경위도로 이 지역 날씨 정보 가져오기
        let w = try await service.weather(for: .init(latitude: coord.latitude,
                                                     longitude: coord.longitude))
        
        // 도씨로 변환
        let tempC = Int((w.currentWeather.temperature.converted(to: .celsius).value).rounded())
        
        // 한시간동안 1분단위로 미래 비올 데이터(날씨 정보 가져오기(미래)) 가져와서 계산하려고
        let nextHour = try? await service.weather(for: .init(latitude: coord.latitude,
                                                             longitude: coord.longitude),
                                                  including: .minute)
        
        // 강수 확률 계산: 1시간 내 최대값을 사용하거나, 없으면 시간별 예보 첫 번째 값 사용
        let prob = nextHour?.reduce(0.0) { max($0, $1.precipitationChance) } ?? w.hourlyForecast.first?.precipitationChance ?? 0
        let precipPercent = Int((prob * 100).rounded())
        
        // SF Symbol 아이콘 이름 가져오기
        let symbol = w.currentWeather.symbolName
        
        return .init(tempC: tempC,
                     precipProb: precipPercent,
                     sfSymbolName: symbol)
    }
    
    static let testValue = WeatherClient { _ in
            .init(tempC: 20, precipProb: 0, sfSymbolName: "sun.max.fill")
    }
}

extension DependencyValues {
    var weatherClient: WeatherClient {
        get { self[WeatherClientKey.self] }
        set { self[WeatherClientKey.self] = newValue }
    }
}

struct WeatherSnapshot: Equatable {
    let tempC: Int
    let precipProb: Int
    let sfSymbolName: String
}
