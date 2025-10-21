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
    
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()
            
            Map(position: $store.camera)
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.5))
            
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
            
            VStack {
                VStack(spacing: 20) {
                    Text("닉네임 보이는 칸입니다")
                        .font(.headline)
                        .foregroundColor(.white)
                    
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
                .padding(.top, 40)
                
                Spacer()
                
                VStack(spacing: 16) {
                    ForEach(0..<1, id: \.self) { index in
                        if let goal = store.runningGoal {
                            RunningGoalCard(
                                title: goal.title,
                                distance: "0.0km / \(goal.distanceGoal)km",
                                progress: "0%",
                                time: "\(goal.startTime.formatted(date: .omitted, time: .shortened)) ~ \(goal.endTime.formatted(date: .omitted, time: .shortened))"
                            )
                        } else {
                            Text("러닝 목표가 없습니다")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Button {
                    
                } label: {
                    Image(systemName: "figure.run")
                        .foregroundStyle(.white)
                        .font(.system(size: 32))
                        .padding(32)
                        .background(Circle().fill(Color.lightGray.opacity(0.2)))
                        .shadow(radius: 8)
                }
                .padding(.bottom, 100)
            }
            
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
        .task { store.send(.onAppear) }
        .navigationDestination(
            item: $store.scope(state: \.planning, action: \.planning)
        ) { addDateStore in
            NavigationStack {
                PlanningView(store: addDateStore)
                    .toolbar(.hidden, for: .tabBar)
            }
        }
    }
}

#Preview {
    HomeView(store: Store(initialState: Home.State()) {
        Home()
    })
}
