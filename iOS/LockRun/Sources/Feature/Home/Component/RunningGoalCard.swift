//
//  RunningGoalCard.swift
//  LockRun
//
//  Created by 전준영 on 10/16/25.
//

import SwiftUI

struct RunningGoalCard: View {
    
    var title: String
    var distance: String
    var progress: String
    var time: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(distance, systemImage: "ruler")
                Spacer()
                Label(progress, systemImage: "moon")
            }
            .font(.caption)
            
            Text(title)
                .font(.headline)
            
            Text(time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial.opacity(0.7))
        .cornerRadius(16)
    }
    
}

#Preview {
    RunningGoalCard(title: "10Kg빼자",
                    distance: "0.0km / 5.0km",
                    progress: "0%",
                    time: "20:00 ~ 22:00"
                    )
}
