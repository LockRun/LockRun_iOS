//
//  RunningGoalCard.swift
//  LockRun
//
//  Created by 전준영 on 10/16/25.
//

import SwiftUI
import ManagedSettings

struct RunningGoalCard: View {
    
    var title: String
    var distance: String
    var progress: String
    var time: String
    var apps: [ApplicationToken] = []
    var onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(distance,
                      systemImage: "ruler")
                
                Spacer()
                
                Label(progress,
                      systemImage: "moon")
                
                Button {
                    onEdit()
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                        .padding(4)
                        .background(Color.black.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .font(.caption)
            
            HStack {
                Text(title)
                    .font(.headline)
                
                if !apps.isEmpty {
                    Text("제어된 앱")
                        .font(.headline)
                }
            }
            
            HStack(alignment: .center) {
                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !apps.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(apps, id: \.self) { app in
                                Label(app)
                                    .labelStyle(.iconOnly)
                                    .scaleEffect(1.2)
                            }
                        }
                    }
                }
            }
            
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
    ){
        
    }
}
