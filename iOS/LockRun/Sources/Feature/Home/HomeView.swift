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
            floatingButton
            
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
    }
    
}

private extension HomeView {
    
    @ViewBuilder
    var backgroundView: some View {
        Color(.background)
            .ignoresSafeArea()
        
        Map(position: $store.camera)
            .ignoresSafeArea()
            .overlay(Color.black.opacity(0.5))
            .overlay(Color.black.opacity(store.runningState == .running ? 0.3 : 0.5))
            .onChange(of: store.runningState) { _, running in
                withAnimation(.linear(duration: 0.1)) {
                    if let coord = store.coord {
                        let zoomSpan = MKCoordinateSpan(latitudeDelta: running == .running ? 0.02 : 0.05,
                                                        longitudeDelta: running == .running ? 0.02 : 0.05)
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
            headerView
            Spacer()
            runningInfoView
            runButton
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
            VStack(spacing: 16) {
                Text("러닝 목표 달성까지 남은 시간")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("01:59:58")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.blue.opacity(0.8))
                
                Capsule()
                    .fill(Color.black.opacity(0.3))
                    .frame(height: 48)
                    .overlay(
                        Text("오늘도 어제보다 강한 나를 만들어보자!")
                            .foregroundColor(.white)
                            .font(.subheadline)
                    )
                    .padding(.horizontal, 32)
            }
            .padding(.top, 40)
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
                    time: "\(goal.startTime.formatted(date: .omitted, time: .shortened)) ~ \(goal.endTime.formatted(date: .omitted, time: .shortened))"
                )
                .padding(.horizontal, 24)
            } else {
                Text("러닝 목표가 없습니다")
                    .foregroundColor(.gray)
            }
        } else {
            VStack {
                VStack(alignment: .leading) {
                    Text("러닝 목표")
                        .foregroundColor(.white)
                    ProgressView(value: 0.8, total: 2.0)
                        .progressViewStyle(.linear)
                        .tint(.blue)
                    HStack {
                        Text("0.8Km").foregroundColor(.white)
                        Spacer()
                        Text("2Km").foregroundColor(.gray)
                    }
                    .font(.caption)
                }
                .padding()
                .background(Color.black.opacity(0.4))
                .cornerRadius(20)
                
                //                RoundedRectangle(cornerRadius: 20)
                //                    .fill(Color.lightGrays.opacity(0.2))
                //                    .frame(height: 80)
                //                    .overlay(realTimeInfo)
                //                    .padding(.horizontal, 24)
            }
            .padding(.horizontal, 32)
        }
    }
    
    @ViewBuilder
    var realTimeInfo: some View {
        VStack {
            CommonText(text: "실시간 정보", font: .bold18, color: .white)
                .padding(.top, 12)
            Spacer()
            HStack(spacing: 100) {
                HStack(spacing: 8) {
                    CommonText(text: "0.8km", font: .bold20, color: .white)
                    CommonText(text: "/ 2km", font: .bold18, color: .gray)
                }
                CommonText(text: "50calorie", font: .bold20, color: .white)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
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
            }
        }
    }
    
    var floatingButton: some View {
        Group {
            if store.runningState == .idle {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            store.send(.plusButtonTapped)
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.top, 40)
                    .padding(.trailing, 20)
                    Spacer()
                }
            }
        }
    }
    
}

#Preview {
    HomeView(store: Store(initialState: Home.State()) {
        Home()
    })
}
