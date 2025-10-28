//
//  HomeReducer.swift
//  LockRun
//
//  Created by 전준영 on 10/15/25.
//

import Foundation
import ComposableArchitecture
import _MapKit_SwiftUI

@Reducer
struct Home: Reducer {
    
    @ObservableState
    struct State: Equatable {
        @Presents var planning: Planning.State?
        
        var camera: MapCameraPosition = .region(.init(
            center: .init(latitude: 37.5665, longitude: 126.9780),
            span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
        var coord: Coordinate?
        var placeName: String = "위치 확인중..."
        
        var temperatureC: Int?
        var precipProbPercent: Int?
        var conditionSymbol: String?
        var isLoadingWeather = false
        var runningGoal: RunningGoalData?
        
        var runningState: RunningState = .idle
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case plusButtonTapped
        case planning(PresentationAction<Planning.Action>)
        case notifyTabbarHide(Bool)
        
        case onAppear
        case locationUpdated(CLLocationCoordinate2D)
        case placeResolved(String)
        case fetchWeather
        case weatherResponse(Result<WeatherSnapshot, Error>)
        case runningGoalLoaded(RunningGoalData?)
        
        case startRunning
        case pauseRunning
        case resumeRunning
        case stopRunning
    }
    
    @Dependency(\.weatherClient) var weatherClient
    @Dependency(\.locationClient) var locationClient
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .plusButtonTapped:
                state.planning = Planning.State()
                return .send(.notifyTabbarHide(true))
                
            case .planning(.dismiss):
                return .send(.notifyTabbarHide(false))
                
            case .planning(.presented(.cancelButtonTapped)):
                state.planning = nil
                return .none
                
            case .onAppear:
                return .run { send in
                    let coord = await locationClient.request()
                    let name = await locationClient.resolvePlaceName(coord)
                    let goal = SwiftDataDBManager.shared.fetchRunningGoal()
                    await send(.locationUpdated(coord))
                    await send(.placeResolved(name))
                    await send(.fetchWeather)
                    await send(.runningGoalLoaded(goal))
                }
                
            case let .locationUpdated(cl):
                state.coord = Coordinate(latitude: cl.latitude, longitude: cl.longitude)
                state.camera = .region(.init(
                    center: cl,
                    span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
                return .none
                
                
            case let .placeResolved(name):
                state.placeName = name.isEmpty ? "현재 위치" : name
                return .none
                
            case .fetchWeather:
                guard let c = state.coord else { return .none }
                state.isLoadingWeather = true
                return .run { [c] send in
                    do {
                        let snap = try await weatherClient.current(CLLocationCoordinate2D(c))
                        await send(.weatherResponse(.success(snap)))
                    } catch {
                        await send(.weatherResponse(.failure(error)))
                    }
                }
                
            case let .weatherResponse(.success(s)):
                state.isLoadingWeather = false
                state.temperatureC = s.tempC
                state.precipProbPercent = s.precipProb
                state.conditionSymbol = s.sfSymbolName
                return .none
                
            case .weatherResponse(.failure(_)):
                state.isLoadingWeather = false
                return .none
                
            case let .runningGoalLoaded(goal):
                state.runningGoal = goal
                return .none
                
            case .startRunning:
                state.runningState = .running
                return .send(.notifyTabbarHide(true))
                
            case .pauseRunning:
                state.runningState = .paused
                return .none
                
            case .resumeRunning:
                state.runningState = .running
                return .none
                
            case .stopRunning:
                state.runningState = .idle
                return .send(.notifyTabbarHide(false))
                
            default:
                return .none
            }
        }
        .ifLet(\.$planning, action: \.planning) {
            Planning()
        }
    }
    
}
