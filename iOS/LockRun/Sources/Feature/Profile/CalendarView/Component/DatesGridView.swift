//
//  DatesGridView.swift
//  LockRun
//
//  Created by 전준영 on 10/22/25.
//

import SwiftUI
import ComposableArchitecture

struct DatesGridView: View {
    
    @ObservedObject var viewStore: ViewStoreOf<CalendarRe>
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(viewStore.dates) { value in
                if value.day != -1 {
                    Button {
                        viewStore.send(.date(value.date))
                    } label: {
                        Text("\(value.day)")
                            .frame(maxWidth: .infinity, minHeight: 32)
                            .padding(4)
                            .background(
                                Circle()
                                    .fill(isSelected(date: value.date) ? .blue : .clear)
                            )
                            .foregroundColor(isSelected(date: value.date) ? .white : textColor(for: value.date))
                    }
                } else {
                    Text("")
                        .frame(maxWidth: .infinity, minHeight: 32)
                        .hidden()
                }
            }
        }
        .padding(.horizontal, 8)
    }
    
    /// 현재 선택된 날짜 여부
    private func isSelected(date: Date) -> Bool {
        Calendar.current.isDate(viewStore.currentDate, inSameDayAs: date)
    }
    
    /// 요일별 색상 지정
    private func textColor(for date: Date) -> Color {
        let weekday = Calendar.current.component(.weekday, from: date)
        return weekday == 1 ? .sundayNormal : .white
    }
}
