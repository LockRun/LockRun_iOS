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
        Text("Hello, profile!")
    }
}

#Preview {
    ProfileView(store: Store(initialState: Profile.State()) {
        Profile()
    })
}
