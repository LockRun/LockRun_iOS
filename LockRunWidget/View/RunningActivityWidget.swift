//
//  RunningActivityWidget.swift
//  LockRun
//
//  Created by 전준영 on 11/10/25.
//

import SwiftUI
import WidgetKit
import ActivityKit

struct RunningActivityWidget: Widget {
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RunningAttributes.self) { context in
            VStack(alignment: .leading,
                   spacing: 10) {
                HStack(alignment: .bottom,
                       spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(context.state.distance, specifier: "%.2f")")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("km")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Text("거리")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(formatTime(context.state.elapsedTime))")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("시간")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.state.pace)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("페이스")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.leading, 20)
                
                ProgressView(value: context.state.distance / context.attributes.goalDistance)
                    .tint(.blue)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 20)
                
                Text("목표 \(context.attributes.goalDistance, specifier: "%.2f")km 달성까지 파이팅!")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 20)
            }
            .padding(.vertical, 10)
            .activityBackgroundTint(.black)
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) { //확장 했을때
                    HStack {
                        Text("🏃‍♂️ \(formatTime(context.state.elapsedTime))")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(context.state.distance, specifier: "%.2f") km")
                            .font(.subheadline)
                    }
                    .padding(.horizontal)
                }
            } compactLeading: {
                Text("\(Int(context.state.distance))km")
                    .font(.caption2)
                    .bold()
                    .foregroundColor(.white)
            } compactTrailing: {
                if context.state.isRunning {
                    Button(intent: PauseRunningIntent()) {
                        Image(systemName: "pause.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                } else {
                    Button(intent: ResumeRunningIntent()) {
                        Image(systemName: "play.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            } minimal: {
                Text("🏃")
            }
        }
    }
}

func formatTime(_ seconds: Int) -> String {
    let h = seconds / 3600
    let m = (seconds % 3600) / 60
    let s = seconds % 60
    if h > 0 {
        return String(format: "%d:%02d:%02d", h, m, s)
    } else {
        return String(format: "%02d:%02d", m, s)
    }
}
