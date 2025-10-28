//
//  WeekdayHeaderView.swift
//  LockRun
//
//  Created by 전준영 on 10/22/25.
//

import SwiftUI

struct WeekdayHeaderView: View {
    
    private let weekday: [String] = ["일", "월", "화", "수", "목", "금", "토"]
    
    var body: some View {
        HStack {
            ForEach(weekday, id: \.self) { day in
                Text(day)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(day == "일" ? .sundayNormal : .white)
            }
        }
        .padding(.bottom, 5)
    }
    
}

#Preview {
    WeekdayHeaderView()
}
