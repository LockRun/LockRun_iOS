//
//  DateChangeView.swift
//  LockRun
//
//  Created by 전준영 on 10/23/25.
//

import SwiftUI
import ComposableArchitecture

struct DateChangeView: View {
    
    @Bindable var store: StoreOf<DateChange>
    
    private var availableYears: [Int] {
        let thisYear = Calendar.current.component(.year, from: .now)
        return Array(2024...thisYear)
    }
    
    private let allMonths = Array(1...12)
    
    var body: some View {
        ZStack {
            Color(.darkSheetGray)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Picker("연도", selection: $store.selectedYear) {
                        ForEach(availableYears, id: \.self) { year in
                            CommonText(text: "\(String(year))년",
                                       font: .bold20,
                                       color: .white)
                            .tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                    
                    Picker("월", selection: $store.selectedMonth) {
                        ForEach(allMonths, id: \.self) { month in
                            CommonText(text: "\(String(month))월",
                                       font: .bold20,
                                       color: .white)
                            .tag(month)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .frame(height: 150)
                
                CommonButton(icon: nil,
                             backgroundColor: .darkGreen,
                             text: .complete,
                             textColor: .white,
                             symbolColor: nil,
                             cornerRadius: 8,
                             haptic: true) {
                    store.send(.confirmTapped)
                }
                             .padding(.top, 16)
            }
            .padding()
        }
    }
    
}

#Preview {
    DateChangeView(store: Store(initialState: DateChange.State()) {
        DateChange()
    })
}
