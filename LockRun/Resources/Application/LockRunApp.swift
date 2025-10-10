//
//  LockRunApp.swift
//  LockRun
//
//  Created by 전준영 on 10/10/25.
//

import SwiftUI
import SwiftData

@main
struct LockRunApp: App {
    
    @StateObject private var locationManager = LocationManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
