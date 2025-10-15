//
//  CustomTabbar.swift
//  LockRun
//
//  Created by 전준영 on 10/15/25.
//

import SwiftUI
import ComposableArchitecture

struct CustomTabbar: View {
    
    @Bindable var store: StoreOf<Tabbar>
    @Namespace private var animation
    
    var body: some View {
        HStack {
            ForEach(TabComponent.allCases, id: \.self) { tab in
                Button {
                    store.send(.tabChanged(tab))
                } label: {
                    ZStack {
                        if store.selectedTab == tab {
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 80, height: 40)
                                .matchedGeometryEffect(id: "selectedTab",
                                                       in: animation)
                        }
                        
                        Image(systemName: tab.icon)
                            .font(.system(size: 20,
                                          weight: .semibold))
                            .foregroundColor(store.selectedTab == tab ? .white : .gray)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 24,
                             style: .continuous)
                .fill(Color.black.opacity(0.6))
                .blur(radius: 4)
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    CustomTabbar(store: Store(initialState: Tabbar.State()) {
        Tabbar()
    })
}
