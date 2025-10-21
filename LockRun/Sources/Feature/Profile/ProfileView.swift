//
//  ProfileView.swift
//  LockRun
//
//  Created by 전준영 on 10/15/25.
//

import SwiftUI
import ComposableArchitecture

struct ProfileView: View {
    
    @Bindable var store: StoreOf<Profile>
    
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()
            
            VStack {
                HStack(spacing: 12) {
                    Image.onboardingImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60,
                               height: 60)
                        .clipShape(Circle())
                        .overlay {
                            Circle().stroke(Color.gray,
                                            lineWidth: 3)
                        }
                    
                    CommonText(text: AppText.Settings.nickname.rawValue,
                               font: .bold18,
                               color: .white)
                }
                
                Divider()
                    .background(Color.lightGray)
                    .frame(height: 1)
                
            }
        }
    }
}

#Preview {
    ProfileView(store: Store(initialState: Profile.State()) {
        Profile()
    })
}
