//
//  HeaderView.swift
//  LockRun
//
//  Created by 전준영 on 10/22/25.
//

import SwiftUI

struct HeaderView: View {
    @AppStorage("nickname") private var nickname = ""
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                CommonText(text: "\(nickname)님, 오늘도 한걸음 전진!",
                           font: .bold20,
                           color: .white)
                
                CommonText(text: "기록을 확인해보세요",
                           font: .bold20,
                           color: .darkGreen)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.leading, 16)
        .padding(.bottom, 40)
    }
}

#Preview {
    HeaderView()
}
