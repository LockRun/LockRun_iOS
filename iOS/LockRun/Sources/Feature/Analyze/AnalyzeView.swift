//
//  AnalyzeView.swift
//  LockRun
//
//  Created by 전준영 on 10/15/25.
//

import SwiftUI
import ComposableArchitecture

struct AnalyzeView: View {
    
    @Bindable var store: StoreOf<Analyze>
    
    var body: some View {
        Text("Hello, analyze!")
    }
}

#Preview {
    AnalyzeView(store: Store(initialState: Analyze.State()) {
        Analyze()
    })
}
