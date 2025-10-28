//
//  CalendarDetailView.swift
//  LockRun
//
//  Created by 전준영 on 10/22/25.
//

import SwiftUI
import ComposableArchitecture

struct CalendarDetailView: View {
    
    let store: StoreOf<CalendarRe>
    
    var body: some View {
        VStack {
            YearMonthHeaderView(store: store)
            
            CalendarView(store: store)
        }
    }
    
}

#Preview {
    CalendarDetailView(
        store: Store(initialState: CalendarRe.State()) {
            CalendarRe()
        }
    )
}
