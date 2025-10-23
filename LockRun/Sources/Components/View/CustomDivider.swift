//
//  CustomDivider.swift
//  LockRun
//
//  Created by 전준영 on 10/21/25.
//

import SwiftUI

struct CustomDivider: View {
    
    let color: Color
    let height: CGFloat
    
    var body: some View {
        Rectangle()
            .frame(height: height)
            .foregroundColor(color)
    }
}

#Preview {
    CustomDivider(color: .blue,
                  height: 4)
}
