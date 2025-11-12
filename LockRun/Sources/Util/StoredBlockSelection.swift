//
//  StoredBlockSelection.swift
//  LockRun
//
//  Created by 전준영 on 10/18/25.
//

import Foundation
import FamilyControls
import ManagedSettings

struct StoredBlockSelection: Codable, Equatable {
    var apps: [ApplicationToken]
    var categories: [ActivityCategoryToken]
    var webDomains: [WebDomainToken]
}

enum FamilyActivityStorage {
    static func save(_ sel: FamilyActivitySelection) {
        let data = StoredBlockSelection(
            apps: Array(sel.applicationTokens),
            categories: Array(sel.categoryTokens),
            webDomains: Array(sel.webDomainTokens)
        )
        let encoded = try? PropertyListEncoder().encode(data)
        AppGroup.defaults.set(encoded, forKey: "ShieldedApps")
        AppGroup.defaults.synchronize()
    }
    
    static func load() -> StoredBlockSelection? {
        guard let data = AppGroup.defaults.data(forKey: "ShieldedApps"),
              let decoded = try? PropertyListDecoder().decode(StoredBlockSelection.self, from: data) else {
            return nil
        }
        return decoded
    }
}
