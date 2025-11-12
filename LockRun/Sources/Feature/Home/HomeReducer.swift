//
//  HomeReducer.swift
//  LockRun
//
//  Created by 전준영 on 10/15/25.
//

import Foundation
import ComposableArchitecture
import _MapKit_SwiftUI
import FamilyControls
import ManagedSettings
import ActivityKit

@Reducer
struct Home: Reducer {
    
    private enum LocationStreamID: Hashable {}
    
    enum WeatherError: Error, Equatable {
        case network
        case decoding
        case unknown
    }
    
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
        var path: [Coordinate] = []
        var totalDistance: Double?
        var selectedApps: [ApplicationToken] = []
        
        var elapsedTime: TimeInterval = 0
        var timeText: String = "00:00:00"
        var heartRateBPM: Int? = nil
        var pace: String? = nil
        var cadence: Int = 0
        var isAuthorized: Bool = false
        var isGoalAchieved: Bool = false
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case plusButtonTapped
        case editButtonTapped
        case planning(PresentationAction<Planning.Action>)
        case notifyTabbarHide(Bool)
        case authorizationResponse(Bool)
        
        case onAppear
        case locationUpdated(Coordinate)
        case placeResolved(String)
        case fetchWeather
        case weatherResponse(Result<WeatherSnapshot, WeatherError>)
        case runningGoalLoaded(RunningGoalData?)
        case appsLoaded([ApplicationToken])
        case remainTime
        
        case startRunning
        case pauseRunning
        case resumeRunning
        case stopRunning
        
        case updateElapsedTime
        case stopTimer
        
        case heartRateUpdated(Double)
        case startHeartRate
        case stopHeartRate
        
        case pedometerDataUpdated(PedometerData)
    }
    
    @Dependency(\.weatherClient) var weatherClient
    @Dependency(\.locationClient) var locationClient
    @Dependency(\.continuousClock) var continuousClock
    @Dependency(\.healthKitClient) var healthKitClient
    @Dependency(\.pedometerClient) var pedometerClient
    
    private let watchSession = WatchSessionManager.shared
    private let liveActivity = LiveActivityManager.shared
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .plusButtonTapped:
                state.planning = Planning.State(isEditMode: false)
                return .send(.notifyTabbarHide(true))
                
            case .planning(.dismiss):
                return .send(.notifyTabbarHide(false))
                
            case .editButtonTapped:
                let kmGoal = state.runningGoal?.distanceGoal
                let startTime = state.runningGoal?.startTime
                let endTime = state.runningGoal?.endTime
                let storedSelection = FamilyActivityStorage.load()
                var preselectedApps = FamilyActivitySelection()
                if let s = storedSelection {
                    preselectedApps.applicationTokens = Set(s.apps)
                    preselectedApps.categoryTokens = Set(s.categories)
                    preselectedApps.webDomainTokens = Set(s.webDomains)
                }
                state.planning = Planning.State(isEditMode: true,
                                                selectedApps: preselectedApps,
                                                kmGoal: kmGoal ?? 1,
                                                startTime: startTime ?? Date(),
                                                endTime: endTime ?? Date())
                return .send(.notifyTabbarHide(true))
                
            case .planning(.presented(.cancelButtonTapped)):
                state.planning = nil
                return .send(.notifyTabbarHide(false))
                
            case let .authorizationResponse(isAuthorized):
                state.isAuthorized = isAuthorized
                return .none
                
            case .onAppear:
                return .merge(
                    .run { send in
                        let stream = watchSession.startHeartRateStream()
                        for await bpm in stream {
                            await send(.heartRateUpdated(bpm))
                        }
                    }
                        .cancellable(id: "watchBPMStream", cancelInFlight: true),
                        .run { send in
                            for await notification in NotificationCenter.default.notifications(named: .pauseRunningRequested) {
                                await send(.pauseRunning)
                            }
                        }
                        .cancellable(id: "pauseIntent", cancelInFlight: true),
                        .run { send in
                            for await notification in NotificationCenter.default.notifications(named: .resumeRunningRequested) {
                                await send(.resumeRunning)
                            }
                        }
                        .cancellable(id: "resumeIntent", cancelInFlight: true),
                    .run { send in
                        let coord = await locationClient.request()
                        let name = await locationClient.resolvePlaceName(coord)
                        let goal = SwiftDataDBManager.shared.fetchRunningGoal()
                        let stored = FamilyActivityStorage.load()
                        let result = try await pedometerClient.requestAuthorization()
                        await send(.authorizationResponse(result))
                        await send(.locationUpdated((Coordinate(latitude: coord.latitude,
                                                                longitude: coord.longitude))))
                        await send(.placeResolved(name))
                        await send(.fetchWeather)
                        await send(.runningGoalLoaded(goal))
                        if let stored = stored {
                            await send(.appsLoaded(stored.apps))
                        }
                    }
                )
                
            case let .appsLoaded(apps):
                state.selectedApps = apps
                return .none
                
            case let .locationUpdated(cl):
                state.coord = cl
                if let currentSpan = state.camera.region?.span {
                    state.camera = .region(.init(center: cl.clLocationCoordinate2D, span: currentSpan))
                }
                if state.runningState == .running {
                    let newCoord = Coordinate(latitude: cl.latitude, longitude: cl.longitude)
                    state.path.append(newCoord)
                    state.totalDistance = state.path.totalDistanceInKm
                    
                    if let goal = state.runningGoal?.distanceGoal,
                       state.totalDistance ?? 0 >= Double(goal),
                       !state.isGoalAchieved {
                        state.isGoalAchieved = true
                        
                        //해제 시점
                        let store = ManagedSettingsStore(named: .studyLock)
                        store.shield.applications = []
                        store.shield.applicationCategories = nil
                        store.shield.webDomains = []
                        
                    }
                }
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
                        await send(.weatherResponse(.failure(.network)))
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
                watchSession.wakeWatchApp()
                if let coord = state.coord {
                    state.path = [coord]
                }
                
                liveActivity.start(
                    goalDistance: Double(state.runningGoal?.distanceGoal ?? Int(5.0)),
                    pace: state.pace ?? "--'--\"",
                    elapsedTime: Int(state.elapsedTime),
                    distance: state.totalDistance ?? 0.0
                )
                
                return .merge(
                    .send(.notifyTabbarHide(true)),
                    .send(.startHeartRate),
                    .run { [continuousClock] send in
                        for await _ in continuousClock.timer(interval: .seconds(1)) {
                            await send(.updateElapsedTime)
                        }
                    }
                        .cancellable(id: "elapsedTimer",
                                     cancelInFlight: true),
                    .run { send in
                        for await coord in locationClient.start() {
                            await send(.locationUpdated(Coordinate(latitude: coord.latitude,
                                                                   longitude: coord.longitude)))
                        }
                    }
                        .cancellable(id: ObjectIdentifier(LocationStreamID.self),
                                     cancelInFlight: true),
                    .run { send in
                        for await data in pedometerClient.startPedometerUpdates() {
                            await send(.pedometerDataUpdated(data))
                        }
                    }
                        .cancellable(id: "pedometer",
                                     cancelInFlight: true)
                )
                
            case .pauseRunning:
                state.runningState = .paused
                watchSession.sendAction("pause")
                return .merge(
                    .send(.stopTimer),
                    .send(.stopHeartRate),
                    .run { _ in pedometerClient.stopPedometerUpdates() }
                )
                
            case .resumeRunning:
                state.runningState = .running
                watchSession.sendAction("resume")
                return .merge(
                    .run { [continuousClock] send in
                        for await _ in continuousClock.timer(interval: .seconds(1)) {
                            await send(.updateElapsedTime)
                        }
                    }
                        .cancellable(id: "elapsedTimer",
                                     cancelInFlight: true),
                    .send(.startHeartRate),
                    .run { send in
                        for await data in pedometerClient.startPedometerUpdates() {
                            await send(.pedometerDataUpdated(data))
                        }
                    }
                        .cancellable(id: "pedometer", cancelInFlight: true)
                )
                
            case .stopRunning:
                state.runningState = .stop
                watchSession.sendAction("stop")
                
                liveActivity.stop(
                    elapsedTime: Int(state.elapsedTime),
                    pace: state.pace ?? "--'--\"",
                    distance: state.totalDistance ?? 0.0
                )
                
                
                //                state.elapsedTime = 0
                //                state.timeText = "00:00:00"
                //                state.heartRateBPM = nil
                //                state.pace = "--'--\""
                //                state.cadence = 0
                //                state.totalDistance = nil
                
                return .merge(
                    .send(.stopTimer),
                    .send(.stopHeartRate),
                    .send(.notifyTabbarHide(false)),
                    .cancel(id: ObjectIdentifier(LocationStreamID.self)),
                    .run { _ in pedometerClient.stopPedometerUpdates() },
                    .cancel(id: "pedometer"),
                )
                
            case .updateElapsedTime:
                state.elapsedTime += 1
                let hours = Int(state.elapsedTime) / 3600
                let minutes = (Int(state.elapsedTime) % 3600) / 60
                let seconds = Int(state.elapsedTime) % 60
                
                state.timeText = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                let elapsed = Int(state.elapsedTime)
                let distance = state.totalDistance ?? 0.0
                let pace = state.pace ?? "--'--\""
                //TODO: 일정 시간마다 알림용 액션만 발생
                return .run { _ in
                    liveActivity.update(
                        elapsedTime: elapsed,
                        pace: pace,
                        distance: distance
                    )
                }
                
            case .stopTimer:
                return .cancel(id: "elapsedTimer")
                
            case .startHeartRate:
                return .run { send in
                    for await bpm in healthKitClient.startHeartRateStream() {
                        await send(.heartRateUpdated(bpm))
                    }
                }
                .cancellable(id: "heartRateStream", cancelInFlight: true)
                
            case .stopHeartRate:
                healthKitClient.stopHeartRateStream()
                return .cancel(id: "heartRateStream")
                
            case let .heartRateUpdated(bpm):
                state.heartRateBPM = Int(bpm.rounded())
                return .none
                
            case let .pedometerDataUpdated(data):
                if let pace = data.pace {
                    let secPerKm = 1000 / pace
                    let min = Int(secPerKm / 60)
                    let sec = Int(secPerKm.truncatingRemainder(dividingBy: 60))
                    state.pace = String(format: "%d'%02d\"", min, sec)
                }
                if let cadence = data.cadence {
                    state.cadence = Int(cadence * 60)
                }
                return .none
                
            default:
                return .none
            }
        }
        .ifLet(\.$planning, action: \.planning) {
            Planning()
        }
    }
    
}
