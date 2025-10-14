//
//  PermissionView.swift
//  LockRun
//
//  Created by 전준영 on 10/12/25.
//

import SwiftUI
import ComposableArchitecture

struct PermissionView: View {
    
    @Bindable var store: StoreOf<Permission>
    
    var body: some View {
        ZStack{
            Color(.background)
                .ignoresSafeArea()
            
            VStack(){
                VStack(alignment: .leading,
                       spacing: 16) {
                    CommonText(text: AppText.OnboardingPermission.title.rawValue,
                               font: .semibold24,
                               color: .white)
                    
                    CommonText(text: AppText.OnboardingPermission.subTitle.rawValue,
                               font: .regular16,
                               color: .white)
                }
                
                Spacer()
                
                VStack(alignment: .leading,
                       spacing: 20) {
                    PermissionExplainView(number: "1",
                                          title: .screenTimePermission,
                                          subtitle: .subScreenTime,
                                          status: store.steps[0])
                    .onTapGesture {
                        store.send(.requestStep(1))
                    }
                    PermissionExplainView(number: "2",
                                          title: .walkingPermission,
                                          subtitle: .subWalking,
                                          status: store.steps[1])
                    .onTapGesture {
                        store.send(.requestStep(2))
                    }
                    PermissionExplainView(number: "3",
                                          title: .locationPermission,
                                          subtitle: .subLocation,
                                          status: store.steps[2])
                    .onTapGesture {
                        store.send(.requestStep(3))
                    }
                    PermissionExplainView(number: "4",
                                          title: .alertPermission,
                                          subtitle: .subAlert,
                                          status: store.steps[3])
                    .onTapGesture {
                        store.send(.requestStep(4))
                    }
                    PermissionExplainView(number: "5",
                                          title: .cameraPermission,
                                          subtitle: .subCamera,
                                          status: store.steps[4])
                    .onTapGesture {
                        store.send(.requestStep(5))
                    }
                }
                       .padding(.top, -32)
                       .padding(.horizontal, 40)
                
                Spacer()
                
                CommonButton(icon: nil,
                             backgroundColor: .lightBlue,
                             text: store.currentButtonTitle,
                             textColor: .white,
                             symbolColor: nil,
                             cornerRadius: 8) {
                    store.send(.requestStep(store.currentStep))
                }
                             .padding(.horizontal, 20)
                             .padding(.bottom, 20)
            }
        }
        .customNavigationBar(isPush: true)
    }
}

#Preview {
    PermissionView(store: Store(initialState: Permission.State()) {
        Permission()
    })
}
