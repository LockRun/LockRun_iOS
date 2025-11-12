//
//  SwiftDataDBManager.swift
//  LockRun
//
//  Created by 전준영 on 10/15/25.
//

import Foundation
import SwiftData

final class SwiftDataDBManager {
    
    static let shared = SwiftDataDBManager()
    let container: ModelContainer
    let modelContext: ModelContext
    
    private init() {
        do {
            let schema = Schema([PermissionStatusData.self,
                                 RunningGoalData.self])
            let config = ModelConfiguration(schema: schema,
                                            isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema,
                                           configurations: [config])
            modelContext = ModelContext(container)
        } catch {
            fatalError("ModelContainer 생성 실패: \(error)")
        }
    }
    
}

extension SwiftDataDBManager {
    
    func updatePermissionStatus(isGranted: Bool = true) {
        do {
            let descriptor = FetchDescriptor<PermissionStatusData>()
            if let existing = try modelContext.fetch(descriptor).first {
                existing.isAllGranted = isGranted
            } else {
                let request = PermissionStatusData(isAllGranted: isGranted)
                modelContext.insert(request)
            }
            try modelContext.save()
        } catch {
            print("updatePermissionStatus 실패: \(error)")
        }
    }
    
    func fetchPermissionStatus() -> Bool {
        do {
            let descriptor = FetchDescriptor<PermissionStatusData>()
            if let existing = try modelContext.fetch(descriptor).first {
                return existing.isAllGranted
            }
        } catch {
            print("fetchPermissionStatus 실패: \(error)")
        }
        return false
    }
    
    func saveRunningGoal(title: String, distanceGoal: Int, startTime: Date, endTime: Date) {
        do {
            let descriptor = FetchDescriptor<RunningGoalData>()
            let existing = try modelContext.fetch(descriptor)
            existing.forEach { modelContext.delete($0) }
            
            let goal = RunningGoalData(title: title,
                                       distanceGoal: distanceGoal,
                                       startTime: startTime,
                                       endTime: endTime)
            modelContext.insert(goal)
            try modelContext.save()
            print("저장 성공")
        } catch {
            print("저장 실패: \(error)")
        }
    }
    
    func deleteRunningGoal() {
        do {
            let descriptor = FetchDescriptor<RunningGoalData>()
            let goals = try modelContext.fetch(descriptor)
            
            if goals.isEmpty {
                return
            }
            
            goals.forEach { modelContext.delete($0) }
            try modelContext.save()
            print("삭제 성공")
            
        } catch {
            print("삭제 실패: \(error)")
        }
    }
    
    func fetchRunningGoal() -> RunningGoalData? {
        do {
            let descriptor = FetchDescriptor<RunningGoalData>()
            return try modelContext.fetch(descriptor).first
        } catch {
            print("가져오기 실패: \(error)")
            return nil
        }
    }
    
}
