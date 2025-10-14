//
//  OnboardingView.swift
//  LockRun
//
//  Created by 전준영 on 10/10/25.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingView: View {
    
    @Bindable var store: StoreOf<Onboarding>
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color(.background)
                    .ignoresSafeArea()
                
                VStack() {
                    CommonText(text: AppText.Onboarding.title.rawValue,
                               font: .semibold24,
                               color: .white)
                    .padding(.top, 32)
                    
                    Spacer()
                    
                    Image.onboardingImage
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        CommonText(text: AppText.Onboarding.subTitle.rawValue,
                                   font: .regular20,
                                   color: .white)
                        
                        CommonButton(icon: nil,
                                     backgroundColor: .white,
                                     text: .start,
                                     textColor: .black,
                                     symbolColor: nil,
                                     cornerRadius: 4) {
                            store.send(.nextButtonTapped)
                        }
                                     .padding(.horizontal, 20)
                                     .padding(.bottom, 20)
                    }
                }
            }
            .navigationDestination(
                item: $store.scope(state: \.permission,
                                   action: \.permission)
            ) { permissionStore in
                PermissionView(store: permissionStore)
            }
        }
    }
}

#Preview {
    OnboardingView(store: Store(initialState: Onboarding.State()) {
        Onboarding()
    })
}
