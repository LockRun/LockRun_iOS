//
//  ProfileReducer.swift
//  LockRun
//
//  Created by 전준영 on 10/15/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct Profile: Reducer {
    
    @ObservableState
    struct State: Equatable {
        @Presents var calendar: CalendarRe.State?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case calendarButtonTapped
        case calendar(PresentationAction<CalendarRe.Action>)
        case notifyTabbarHide(Bool)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .calendarButtonTapped:
                state.calendar = CalendarRe.State()
                return .send(.notifyTabbarHide(true))
                
            case .calendar(.dismiss):
                return .send(.notifyTabbarHide(false))
                
            default:
                return .none
            }
        }
        .ifLet(\.$calendar, action: \.calendar) {
            CalendarRe()
        }
    }
    
}
