//
//  ContentView.swift
//  LockRunWatchApp Watch App
//
//  Created by 전준영 on 11/5/25.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var manager: WorkoutManager
    
    var body: some View {
        VStack {
            Text("❤️ \(manager.heartRate)")
                .font(.largeTitle)
        }
        .onAppear { manager.start() }
    }
}

#Preview {
    ContentView()
}
