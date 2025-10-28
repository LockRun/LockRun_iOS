//
//  PermissionExplainView.swift
//  LockRun
//
//  Created by 전준영 on 10/12/25.
//

import SwiftUI

struct PermissionExplainView: View {
    
    let number: String
    let title: AppText.OnboardingPermission
    let subtitle: AppText.OnboardingPermission
    let status: PermissionStatus
    
    var body: some View {
        HStack(alignment: .top,
               spacing: 12){
            Text(number)
                .customFont(.bold18)
//                .foregroundColor(.white)
                .foregroundColor(status == .granted ? .white : .yellow)
                .frame(width: 24,
                       height: 24)
//                .background(Color.yellow)
                .background(status == .granted ? Color.yellow : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.yellow,
                                lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 4,
                                            style: .continuous))
            
            VStack(alignment: .leading,
                   spacing: 8) {
                CommonText(text: title.rawValue,
                           font: .bold18,
                           color: .white)
                
                CommonText(text: subtitle.rawValue,
                           font: .regular15,
                           color: .gray)
            }
        }
               .frame(maxWidth: .infinity,
                      alignment: .leading)
    }
}

#Preview {
    PermissionExplainView(number: "1",
                          title: .screenTimePermission,
                          subtitle: .subScreenTime,
                          status: .notRequested)
}
