//
//  TabbarReducer.swift
//  LockRun
//
//  Created by 전준영 on 10/15/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct Tabbar: Reducer {
    
    @ObservableState
    struct State: Equatable {
        var selectedTab: TabComponent = .home
        var isTabBarHidden: Bool = false
        var home: Home.State = .init()
        var analyze: Analyze.State = .init()
        var profile: Profile.State = .init()
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case tabChanged(TabComponent)
        case setTabBarHidden(Bool)
        case home(Home.Action)
        case analyze(Analyze.Action)
        case profile(Profile.Action)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Scope(state: \.home, action: \.home) { Home() }
        Scope(state: \.analyze, action: \.analyze) { Analyze() }
        Scope(state: \.profile, action: \.profile) { Profile() }
        
        Reduce { state, action in
            switch action {
            case .tabChanged(let tab):
                state.selectedTab = tab
                return .none
                
            case .setTabBarHidden(let hidden):
                state.isTabBarHidden = hidden
                return .none
                
            case .home(.notifyTabbarHide(let hidden)):
                state.isTabBarHidden = hidden
                return .none
                
            default:
                return .none
            }
        }
    }
    
}
