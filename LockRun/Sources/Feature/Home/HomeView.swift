//
//  HomeView.swift
//  LockRun
//
//  Created by 전준영 on 10/15/25.
//

import SwiftUI
import ComposableArchitecture
import MapKit

struct HomeView: View {
    
    @Bindable var store: StoreOf<Home>
    @AppStorage("nickname") private var nickname = ""
    @State private var showCountdown = false
    
    var body: some View {
        ZStack {
            backgroundView
            contentView
            
            if showCountdown {
                Color.black.opacity(0.7).ignoresSafeArea()
                LottieView(name: "Countdown") {
                    showCountdown = false
                    store.send(.startRunning)
                }
                .frame(width: 180, height: 180)
                .padding(.bottom, 60)
            }
        }
        .task { store.send(.onAppear) }
        .navigationDestination(
            item: $store.scope(state: \.planning, action: \.planning)
        ) { addDateStore in
            NavigationStack {
                PlanningView(store: addDateStore) .toolbar(.hidden, for: .tabBar)
            }
        }
    }
    
}

private extension HomeView {
    
    @ViewBuilder
    var backgroundView: some View {
        Color(.background)
            .ignoresSafeArea()
        
        Map(position: $store.camera, interactionModes: .all){
            if store.runningState == .running {
                UserAnnotation()
            }
            if store.path.count > 1 {
                MapPolyline(coordinates: store.path.map { $0.clLocationCoordinate2D })
                    .stroke(.yellow, lineWidth: 5)
            }
        }
        .ignoresSafeArea()
        .overlay(Color.black.opacity(0.5))
        .overlay(Color.black.opacity(store.runningState == .running ? 0.3 : 0.5))
        .onChange(of: store.runningState) { _, running in
            withAnimation(.linear(duration: 0.1)) {
                if let coord = store.coord {
                    let zoomSpan = MKCoordinateSpan(latitudeDelta: running == .running ? 0.01 : 0.05,
                                                    longitudeDelta: running == .running ? 0.01 : 0.05)
                    store.camera = .region(.init(center: coord.clLocationCoordinate2D,
                                                 span: zoomSpan))
                }
            }
        }
        
        RadialGradient(
            gradient: Gradient(stops: [
                .init(color: Color(.background).opacity(0.1), location: 0.45),
                .init(color: Color(.background).opacity(1.0), location: 1.0)
            ]),
            center: .center,
            startRadius: 0,
            endRadius: 400
        )
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    var contentView: some View {
        VStack {
            switch store.runningState {
            case .idle:
                headerView
                Spacer()
                runningInfoView
                runButton
                
            case .running, .paused:
                headerView
                Spacer()
                runningInfoView
                runButton
                
            case .stop:
                stoppedView
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    var headerView: some View {
        if store.runningState == .idle {
            VStack(spacing: 20) {
                HStack {
                    VStack {
                        Text("\(nickname)님 안녕하세요")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("오늘도 러닝 어때요?")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.leading, 40)
                
                weatherInfo
            }
            .padding(.top, 40)
        } else {
            VStack(spacing: 12) {
                Capsule()
                    .fill(Color.black.opacity(0.3))
                    .frame(height: 44)
                    .overlay(
                        Text("오늘도 어제보다 강한 나를 만들어보자!")
                            .foregroundColor(.white)
                            .font(.subheadline)
                    )
                    .padding(.horizontal, 32)
                
                Text(store.timeText)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.blue.opacity(0.8))
                
                HStack(spacing: 24) {
                    VStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                        if let hr = store.heartRateBPM {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(hr)")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("bpm")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        } else {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("--")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("bpm")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    
                    VStack {
                        Image(systemName: "figure.run")
                            .foregroundColor(.green)
                            .font(.title2)
                        if let pace = store.pace {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(pace)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("/km")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        } else {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("--'--\"")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("/km")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    
                    VStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.yellow)
                            .font(.title2)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(String(format: "%.2f ", store.totalDistance ?? 2.13))
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("km")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    VStack {
                        Image(systemName: "metronome")
                            .foregroundColor(.cyan)
                            .font(.title2)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(store.cadence)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            Text("spm")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .padding(.top, 4)
            }
            .padding(.top, 32)
        }
    }
    
    @ViewBuilder
    var weatherInfo: some View {
        HStack(spacing: 20) {
            Label("\(store.temperatureC.map{"\($0)°C"} ?? "—")",
                  systemImage: store.conditionSymbol ?? "questionmark")
            
            Label("\(store.precipProbPercent.map{"\($0)%"} ?? "—")",
                  systemImage: "cloud.rain")
            
            Label(store.placeName, systemImage: "location")
        }
        .font(.subheadline)
        .foregroundColor(.white)
        .padding(12)
        .background(.ultraThinMaterial.opacity(0.7))
        .cornerRadius(16)
    }
    
    @ViewBuilder
    var runningInfoView: some View {
        if store.runningState == .idle {
            if let goal = store.runningGoal {
                RunningGoalCard(
                    title: goal.title,
                    distance: "0.0km / \(goal.distanceGoal)km",
                    progress: "0%",
                    time: "\(goal.startTime.formatted(date: .omitted, time: .shortened)) ~ \(goal.endTime.formatted(date: .omitted, time: .shortened))",
                    apps: store.selectedApps
                ){
                    store.send(.editButtonTapped)
                }
                .padding(.horizontal, 24)
            } else {
                Button {
                    store.send(.plusButtonTapped)
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                        
                        Text("러닝 목표 추가")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        Text("나만의 러닝 계획을 만들어보세요")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption)
                    }
                    .padding(.vertical, 30)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(LinearGradient(
                                colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    )
                    .padding(.horizontal, 32)
                }
            }
        } else {
            VStack {
                VStack(alignment: .leading) {
                    Text("러닝 목표")
                        .foregroundColor(.white)
                    
                    if let goalDistance = store.runningGoal?.distanceGoal, goalDistance > 0 {
//                        ProgressView(
//                            value: store.totalDistance ?? 0,
//                            total: Double(goalDistance)
//                        )
//                        .progressViewStyle(.linear)
//                        .tint(.blue)
                        
                        ProgressView(
                            value: min(store.totalDistance ?? 0, Double(goalDistance)),
                            total: Double(goalDistance)
                        )
                        .progressViewStyle(.linear)
                        .tint(store.isGoalAchieved ? .green : .blue)
                    } else {
                        ProgressView(value: 0, total: 1)
                            .progressViewStyle(.linear)
                            .tint(.gray)
                    }
                    
                    HStack {
                        if store.isGoalAchieved {
                            Text("🎉 목표 \(store.runningGoal?.distanceGoal ?? 0)km 달성 완료!")
                                .foregroundColor(.green)
                                .font(.caption)
                                .fontWeight(.semibold)
                        } else {
                            Text(String(format: "%.2fKm", store.totalDistance ?? 0))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(store.runningGoal?.distanceGoal ?? 0)Km")
                                .foregroundColor(.gray)
                        }
                        
//                        Text(String(format: "%.2fKm", store.totalDistance ?? 0))
//                            .foregroundColor(.white)
//                        
//                        Spacer()
//                        
//                        Text("\(store.runningGoal?.distanceGoal ?? 0)Km")
//                            .foregroundColor(.gray)
                    }
                    .font(.caption)
                }
                .padding()
                .background(Color.black.opacity(0.4))
                .cornerRadius(20)
            }
            .padding(.horizontal, 32)
        }
    }
    
    var runButton: some View {
        Group {
            switch store.runningState {
            case .idle:
                Button {
                    showCountdown = true
                } label: {
                    Image(systemName: "figure.run")
                        .foregroundStyle(.white)
                        .font(.system(size: 32))
                        .padding(32)
                        .background(Circle().fill(Color.lightGrays.opacity(0.2)))
                        .shadow(radius: 8)
                }
                .padding(.bottom, 100)
                
            case .running:
                HStack(spacing: 40){
                    Button {
                        store.send(.stopRunning)
                    } label: {
                        Image(systemName: "stop.fill")
                            .foregroundStyle(.white)
                            .font(.system(size: 32))
                            .padding(32)
                            .background(Circle().fill(Color.lightGrays.opacity(0.2)))
                            .shadow(radius: 8)
                    }
                    
                    Button {
                        store.send(.pauseRunning)
                    } label: {
                        Image(systemName: "pause.fill")
                            .foregroundStyle(.white)
                            .font(.system(size: 32))
                            .padding(32)
                            .background(Circle().fill(Color.lightGrays.opacity(0.2)))
                            .shadow(radius: 8)
                    }
                }
                .padding(.bottom, 20)
                
            case .paused:
                VStack(spacing: 16) {
                    Button {
                        store.send(.stopRunning)
                    } label: {
                        Text("여기까지 달릴게요")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(12)
                    }
                    
                    Button {
                        store.send(.resumeRunning)
                    } label: {
                        Text("다시 시작할까요?")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                
            case .stop:
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    var stoppedView: some View {
        VStack(spacing: 20) {
            ZStack(alignment: .bottom) {
                Map(position: $store.camera, interactionModes: []) {
                    if store.path.count > 1 {
                        MapPolyline(coordinates: store.path.map { $0.clLocationCoordinate2D })
                            .stroke(.yellow, lineWidth: 5)
                    }
                }
                .ignoresSafeArea(edges: .top)
                .frame(height: 350)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                VStack(spacing: 8) {
                    Text("러닝 완료 🎉")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("오늘도 멋진 달리기였어요")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.subheadline)
                }
                .padding(.bottom, 24)
            }
            
            VStack(spacing: 24) {
                HStack(spacing: 40) {
                    summaryItem(icon: "clock", title: "시간", value: store.timeText)
                    summaryItem(icon: "location.fill", title: "거리", value: String(format: "%.2f km", store.totalDistance ?? 0))
                }
                HStack(spacing: 40) {
                    summaryItem(icon: "figure.run", title: "페이스", value: store.pace ?? "--'--\"")
                    summaryItem(icon: "metronome", title: "케이던스", value: "\(store.cadence) spm")
                }
            }
            .padding()
            .background(Color.black.opacity(0.4))
            .cornerRadius(24)
            .padding(.horizontal, 32)
            
            Button {
                store.send(.notifyTabbarHide(false))
                store.runningState = .idle
            } label: {
                Text("기록 저장하고 종료하기")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(16)
            }
            .padding(.horizontal, 40)
            .padding(.top, 12)
        }
    }
    
    @ViewBuilder
    func summaryItem(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
            Text(title)
                .foregroundColor(.gray)
                .font(.caption)
            Text(value)
                .font(.title3)
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }
    }
    
    
}

#Preview {
    HomeView(store: Store(initialState: Home.State()) {
        Home()
    })
}
