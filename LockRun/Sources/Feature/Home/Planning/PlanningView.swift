//
//  PlanningView.swift
//  LockRun
//
//  Created by 전준영 on 10/17/25.
//

import SwiftUI
import ComposableArchitecture

struct PlanningView: View {
    
    @Bindable var store: StoreOf<Planning>
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        store.send(.toggleFamilyPicker(true))
                    } label: {
                        HStack {
                            Image(systemName: "lock.fill")
                            
                            Text("차단할 앱 선택하기")
                        }
                    }
                    .familyActivityPicker(isPresented: $store.isFamilyPickerPresented,
                                          selection: $store.selectedApps)
                    
                    if !store.selectedApps.applicationTokens.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(Array(store.selectedApps.applicationTokens),
                                        id: \.self) { token in
                                    Label(token)
                                        .labelStyle(.iconOnly)
                                        .scaleEffect(1.2)
                                        .padding(2)
                                }
                            }
                        }
                    }
                } header: {
                    Text("앱 차단")
                } footer: {
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.gray)
                            .font(.caption)
                        
                        Text("최대 10개의 앱까지 선택할 수 있습니다.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 2)
                }
                
                Section {
                    DatePicker("시작 시간", selection: $store.startTime,
                               displayedComponents: .hourAndMinute)
                    
                    DatePicker("종료 시간", selection: $store.endTime,
                               displayedComponents: .hourAndMinute)
                } header: {
                    Text("시간 설정")
                } footer: {
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.gray)
                            .font(.caption)
                        
                        Text("시작 시간부터 종료 시간까지 앱이 차단됩니다. \n설정된 시간이 지나거나 목표 거리를 달성하면 자동으로 해제됩니다.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 2)
                }
                
                Section {
                    Stepper(value: $store.kmGoal, in: 1...50) {
                        Text("\(store.kmGoal) km")
                    }
                } header: {
                    Text("목표 거리")
                } footer: {
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.gray)
                            .font(.caption)
                        
                        Text("목표 거리는 1km부터 50km까지 설정할 수 있습니다.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 2)
                }
                
                if store.isEditMode == true {
                    Section {
                        Button(role: .destructive) {
                            store.send(.deleteButtonTapped)
                        } label: {
                            HStack {
                                Spacer()
                                Text("삭제하기")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(store.isEditMode == true ? "러닝 목표 수정" : "러닝 목표 설정")
            .customNavigationBar(isPush: true)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(store.isEditMode == true ? "수정" : "완료") {
                        store.send(.saveButtonTapped)
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
}

#Preview {
    PlanningView(store: Store(initialState: Planning.State()) {
        Planning()
    })
}
