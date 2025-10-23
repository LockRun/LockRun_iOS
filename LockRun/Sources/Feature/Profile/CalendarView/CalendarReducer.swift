//
//  CalendarReducer.swift
//  LockRun
//
//  Created by 전준영 on 10/22/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct CalendarRe {
    
    @ObservableState
    struct State: Equatable {
        // 달력 기본 상태
        var currentDate: Date = Date()
        var dates: [DateValue] = DateManager.extractDate(currentMonth: 0)
        // 날짜 변경 시트
        @Presents var dateChange: DateChange.State?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        // 달력 관련
        case updateMonth(Int)// 특정 month offset으로 이동
        case didSwipeLeft// 다음 달로 스와이프
        case didSwipeRight// 이전 달로 스와이프
        case date(Date)// 특정 날짜 선택
        // 날짜 변경 시트 관련
        case dateChange(PresentationAction<DateChange.Action>)
        case showDateChangeSheet(Bool)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
                // 현재 날짜 선택 → 년/월 문자열 업데이트 + dates 채우기
            case .date(let date):
                state.currentDate = date
                state.dates = DateManager.extractDate(currentMonth: state.monthOffset)
                return .none
                
                // 특정 오프셋으로 월 이동
            case let .updateMonth(offset):
                if let newDate = Calendar.current.date(byAdding: .month, value: offset, to: Date()) {
                    state.currentDate = newDate
                    state.dates = DateManager.extractDate(currentMonth: offset)
                }
                return .none
                
                // 다음 달로 스와이프
            case .didSwipeLeft:
                let calendar = Calendar.current
                let year = calendar.component(.year, from: state.currentDate)
                let month = calendar.component(.month, from: state.currentDate)
                let currentYear = calendar.component(.year, from: Date())
                
                // 현재 연도와 월 기준으로 이동 제한
                if year > currentYear {
                    // 미래 연도로는 안 감
                    return .none
                }
                
                if let newDate = calendar.date(byAdding: .month, value: 1, to: state.currentDate) {
                    let newYear = calendar.component(.year, from: newDate)
                    let newMonth = calendar.component(.month, from: newDate)
                    // 현재 연도의 12월일 때는 다음 해 1월 허용
                    if year == currentYear && month == 12 && newYear == currentYear + 1 && newMonth == 1 {
                        state.currentDate = newDate
                        state.dates = DateManager.extractDate(currentMonth: state.monthOffset)
                    }
                    // 현재 연도의 1~11월이면 다음 달 허용
                    else if year == currentYear && month < 12 && newYear == currentYear && newMonth == month + 1 {
                        state.currentDate = newDate
                        state.dates = DateManager.extractDate(currentMonth: state.monthOffset)
                    }
                }
                return .none
                
                // 이전 달로 스와이프
            case .didSwipeRight:
                let calendar = Calendar.current
                let year = calendar.component(.year, from: state.currentDate)
                let month = calendar.component(.month, from: state.currentDate)
                
                // 최소를 2024년 1월로 제한
                if year == 2024 && month == 1 {
                    return .none
                }
                if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: state.currentDate) {
                    state.currentDate = newDate
                    state.dates = DateManager.extractDate(currentMonth: state.monthOffset)
                }
                return .none
                
                // 날짜 변경 시트 표시 여부
            case .showDateChangeSheet(true):
                let year = state.selectedYear
                let month = state.selectedMonth
                state.dateChange = DateChange.State(selectedYear: year,
                                                    selectedMonth: month)
                return .none
                
            case .showDateChangeSheet(false):
                state.dateChange = nil
                return .none
                
                // DateChange 시트에서 "확인" 눌렀을 때 → 새로운 날짜로 반영
            case .dateChange(.presented(.confirmTapped)):
                if let year = state.dateChange?.selectedYear,
                   let month = state.dateChange?.selectedMonth {
                    var components = DateComponents()
                    components.year = year
                    components.month = month
                    components.day = 1
                    
                    if let newDate = Calendar.current.date(from: components) {
                        state.currentDate = newDate
                        state.dates = DateManager.extractDate(currentMonth: state.monthOffset)
                    }
                }
                state.dateChange = nil
                return .none
                
            default:
                return .none
            }
        }
        .ifLet(\.$dateChange, action: \.dateChange) {
            DateChange()
        }
    }
}

extension CalendarRe.State {
    var year: String {
        DateManager.getYearAndMonthString(currentDate: currentDate)[0]
    }
    var month: String {
        DateManager.getYearAndMonthString(currentDate: currentDate)[1]
    }
    var selectedYear: Int {
        Calendar.current.component(.year, from: currentDate)
    }
    var selectedMonth: Int {
        Calendar.current.component(.month, from: currentDate)
    }
    var monthOffset: Int {
        Calendar.current.dateComponents([.month], from: Date(), to: currentDate).month ?? 0
    }
}
