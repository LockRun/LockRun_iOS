//
//  HomeReducer.swift
//  LockRun
//
//  Created by 전준영 on 10/15/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct Home: Reducer {
    
    @ObservableState
    struct State: Equatable {
        
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            default:
                return .none
            }
        }
    }
    
}
