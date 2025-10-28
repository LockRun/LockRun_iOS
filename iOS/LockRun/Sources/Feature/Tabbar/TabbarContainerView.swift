//
//  TabbarContainerView.swift
//  LockRun
//
//  Created by 전준영 on 10/15/25.
//

import SwiftUI
import ComposableArchitecture

struct TabbarContainerView: View {
    
    @Bindable var store: StoreOf<Tabbar>
    
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()
            
            switch store.selectedTab {
            case .home:
                NavigationStack{
                    HomeView(store: store.scope(state: \.home,
                                                action: \.home))
                    .toolbar(.hidden, for: .navigationBar)
                }
                
            case .analyze:
                AnalyzeView(store: store.scope(state: \.analyze,
                                               action: \.analyze))
                
            case .profile:
                NavigationStack{
                    ProfileView(store: store.scope(state: \.profile,
                                                   action: \.profile))
                    .toolbar(.hidden, for: .navigationBar)
                }
            }
            
            VStack{
                Spacer()
                
                if !store.isTabBarHidden {
                    CustomTabbar(store: store)
                }
            }
        }
    }
}

#Preview {
    TabbarContainerView(store: Store(initialState: Tabbar.State()) {
        Tabbar()
    })
}
