//
//  CalendarMainView.swift
//  LockRun
//
//  Created by 전준영 on 10/22/25.
//

import SwiftUI
import ComposableArchitecture

struct CalendarMainView: View {
    
    @Bindable var store: StoreOf<CalendarRe>
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.background)
                    .ignoresSafeArea()
                
                VStack{
                    HeaderView()
                        .padding(.horizontal, 20)
                        .padding(.top)
                        .padding(.bottom, -30)
                    
                    CalendarDetailView(store: store)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    
                    ScrollView {
                        CalendarRecordView()
                            .padding(.horizontal, 20)
                    }
                }.onAppear {
                    store.send(.date(store.currentDate))
                }
            }
            .customNavigationBar(isPush: true)
        }
    }
}

#Preview {
    CalendarMainView(store: Store(initialState: CalendarRe.State()) {
        CalendarRe()
    })
}
