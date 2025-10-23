//
//  YearMonthHeaderView.swift
//  LockRun
//
//  Created by 전준영 on 10/23/25.
//

import SwiftUI
import ComposableArchitecture

struct YearMonthHeaderView: View {
    
    @Bindable var store: StoreOf<CalendarRe>
    
    var body: some View {
        HStack {
            CommonText(text: "\(store.year)년 \(store.month)",
                       font: .bold18,
                       color: .white)
            
            Button(action: {
                store.send(.showDateChangeSheet(true))
            }, label: {
                Image(systemName: "chevron.down")
                    .foregroundStyle(.white)
            })
        }
        .sheet(
            item: $store.scope(state: \.dateChange, action: \.dateChange)
        ) { dateChangeStore in
            DateChangeView(store: dateChangeStore)
                .presentationDetents([.fraction(0.4)])
        }
    }
}

#Preview {
    YearMonthHeaderView(
        store: Store(initialState: CalendarRe.State()) {
            CalendarRe()
        }
    )
}
