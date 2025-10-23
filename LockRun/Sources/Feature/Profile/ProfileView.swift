//
//  ProfileView.swift
//  LockRun
//
//  Created by 전준영 on 10/15/25.
//

import SwiftUI
import ComposableArchitecture

struct ProfileView: View {
    
    @Bindable var store: StoreOf<Profile>
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    Image.onboardingImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60,
                               height: 60)
                        .clipShape(Circle())
                        .overlay {
                            Circle().stroke(Color.gray,
                                            lineWidth: 1.5)
                        }
                    
                    CommonText(text: AppText.Settings.nickname.rawValue,
                               font: .bold18,
                               color: .white)
                    
                    CommonButton(icon: Image(systemName: "pencil"),
                                 backgroundColor: .darkBlack,
                                 text: nil,
                                 textColor: .clear,
                                 symbolColor: .gray,
                                 cornerRadius: 4,
                                 isIconOnly: true) {
                        
                    }
                                 .frame(width: 20,
                                        height: 20)
                    
                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.top, 12)
                
                CustomDivider(color: .lineDark,
                              height: 8)
                
                VStack(spacing: 20) {
                    CommonButton(icon: Image(systemName: "calendar"),
                                 backgroundColor: .profileButton,
                                 text: .calendar,
                                 textColor: .white,
                                 symbolColor: .darkGreen,
                                 cornerRadius: 8,
                                 height: 66,
                                 hasInternalPadding: true,
                                 spacing: 12,
                                 alignLeft: true) {
                        store.send(.calendarButtonTapped)
                    }
                                 .padding(.horizontal, 32)
                    
                    CommonButton(icon: Image(systemName: "map.fill"),
                                 backgroundColor: .profileButton,
                                 text: .running,
                                 textColor: .white,
                                 symbolColor: .darkGreen,
                                 cornerRadius: 8,
                                 height: 66,
                                 hasInternalPadding: true,
                                 spacing: 12,
                                 alignLeft: true) {
                        
                    }
                                 .padding(.horizontal, 32)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    HStack(spacing: 20) {
                        Button(action: {
                            
                        }) {
                            Text("개인정보처리 방침")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: {
                            
                        }) {
                            Text("이용약관")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text("버전 \(appVersion)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 80)
                }
                .padding(.bottom, 16)
            }
        }
        .navigationDestination(item: $store.scope(state: \.calendar, action: \.calendar)) { store in
            NavigationStack{
                CalendarMainView(store: store)
                    .toolbar(.hidden, for: .tabBar)
            }
        }
    }
}

#Preview {
    ProfileView(store: Store(initialState: Profile.State()) {
        Profile()
    })
}
