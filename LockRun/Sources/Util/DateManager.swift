//
//  DateManager.swift
//  LockRun
//
//  Created by 전준영 on 10/22/25.
//

import Foundation

final class DateManager {
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMMM"
        formatter.locale = Locale(identifier: "ko_kr")
        return formatter
    }()
    
    static func getYearAndMonthString(currentDate: Date) -> [String] {
        let date = formatter.string(from: currentDate)
        return date.components(separatedBy: " ")
    }
    
    /// 현재 캘린더에 보이는 month 구하는 함수
    static func getCurrentMonth(addingMonth: Int) -> Date {
        // 현재 날짜의 캘린더
        let calendar = Calendar.current
        
        // 현재 날짜의 month에 addingMonth의 month를 더해서 새로운 month를 만들어
        // 만약 오늘이 1월 27일이고 addingMonth에 2를 넣으면 3월 27일이됨
        guard let currentMonth = calendar.date(
            byAdding: .month,
            value: addingMonth,
            to: Date()
        ) else { return Date() }
        
        return currentMonth
    }
    
    /// 해당 월의 모든 날짜들을 DateValue 배열로 만들어주는 함수, 모든 날짜를 배열로 만들어야 Grid에서 보여주기 가능
    static func extractDate(currentMonth: Int) -> [DateValue] {
        let calendar = Calendar.current
        
        // getCurrentMonth가 리턴한 month 구해서 currentMonth로
        let currentMonth = getCurrentMonth(addingMonth: currentMonth)
        
        // currentMonth가 리턴한 month의 모든 날짜 구하기
        var days = currentMonth.getAllDates().compactMap { date -> DateValue in
            // 여기서 date = 2023-12-31 15:00:00 +0000
            let day = calendar.component(.day, from: date)
            // 여기서 DateValue = DateValue(id: "uuid", day: 1, date: 2023-12-31 15:00:00 +0000)
            return DateValue(day: day, date: date)
        }
        
        // days로 구한 month의 가장 첫날이 시작되는 요일구하기
        // Int값으로 나옴. 일요일 1 ~ 토요일 7
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        // month의 가장 첫날이 시작되는 요일 이전을 채워주는 과정
        // 만약 1월 1일이 수요일에 시작된다면 일~화요일까지 공백이니까 이 자리를 채워주어야 수요일부터 시작되는 캘린더 모양이 생성됨
        // 그래서 만약 수요일(4)이 시작이라고 하면 일(1)~화(3) 까지 for-in문 돌려서 공백 추가
        // 캘린더 뷰에서 월의 첫 주를 올바르게 표시하기 위한 코드
        for _ in 0 ..< firstWeekday - 1 {
            // 여기서 "day: -1"은 실제 날짜가 아니라 공백을 표시한 개념, "date: Date()"도 임시
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        
        return days
    }
    
}

extension Date {
   // 현재 월의 날짜를 Date 배열로 만들어주는 함수
   func getAllDates() -> [Date] {
       // 현재날짜 캘린더 가져오는거
       let calendar = Calendar.current
       // 현재 월의 첫 날(startDate) 구하기 -> 일자를 지정하지 않고 year와 month만 구하기 때문에 그 해, 그 달의 첫날을 이렇게 구할 수 있음
       let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
       // 현재 월(해당 월)의 일자 범위(날짜 수 가져오는거)
       let range = calendar.range(of: .day, in: .month, for: startDate)!
       // range의 각각의 날짜(day)를 Date로 맵핑해서 배열로!!
       return range.compactMap { day -> Date in
           // to: (현재 날짜, 일자)에 day를 더해서 새로운 날짜를 만듦
           calendar.date(byAdding: .day, value: day - 1, to: startDate) ?? Date()
       }
   }
}

struct DateValue: Identifiable, Equatable {
    var id: String = UUID().uuidString
    var day: Int
    var date: Date
}
