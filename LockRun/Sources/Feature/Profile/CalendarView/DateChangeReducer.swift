//
//  DateChangeReducer.swift
//  LockRun
//
//  Created by 전준영 on 10/23/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct DateChange: Reducer {
    
    @ObservableState
    struct State: Equatable {
        var selectedYear: Int = Calendar.current.component(.year, from: .now)
        var selectedMonth: Int = Calendar.current.component(.month, from: .now)
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case yearChanged(Int)
        case monthChanged(Int)
        case confirmTapped
        case cancelTapped
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .yearChanged(let year):
                state.selectedYear = year
                return .none
                
            case .monthChanged(let month):
                state.selectedMonth = month
                return .none
                
            case .confirmTapped:
                return .none
                
            case .cancelTapped:
                return .none
                
            default:
                return .none
            }
        }
    }
}

