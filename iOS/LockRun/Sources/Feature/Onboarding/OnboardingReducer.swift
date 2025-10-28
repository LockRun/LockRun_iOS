//
//  OnboardingReducer.swift
//  LockRun
//
//  Created by 전준영 on 10/12/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct Onboarding: Reducer {
    
    @ObservableState
    struct State: Equatable {
        @Presents var permission: Permission.State?
//        var contacts: IdentifiedArrayOf<Contact> = []
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case nextButtonTapped
        case permission(PresentationAction<Permission.Action>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .nextButtonTapped:
                state.permission = Permission.State()
                return .none
                
            case .permission:
                return .none
                
            case .binding:
                return .none
            }
        }
        .ifLet(\.$permission, action: \.permission) {
            Permission()
        }
    }
    
}
