//
//  HomeView.swift
//  LockRun
//
//  Created by 전준영 on 10/15/25.
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    
    @Bindable var store: StoreOf<Home>
    
    var body: some View {
        Text("Hello, home!")
    }
}

#Preview {
    HomeView(store: Store(initialState: Home.State()) {
        Home()
    })
}
