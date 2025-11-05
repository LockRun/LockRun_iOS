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
        print("   apps=\(data.apps.count), cats=\(data.categories.count), webs=\(data.webDomains.count)")
        print("   snapshot=\(AppGroup.defaults.dictionaryRepresentation())")
    }
    
    static func load() -> StoredBlockSelection? {
        guard let data = AppGroup.defaults.data(forKey: "ShieldedApps"),
              let decoded = try? PropertyListDecoder().decode(StoredBlockSelection.self, from: data) else {
            print("ShieldedApps 없음 (load)")
            return nil
        }
        print("ShieldedApps 로드 성공: apps=\(decoded.apps.count), cats=\(decoded.categories.count), webs=\(decoded.webDomains.count)")
        return decoded
    }
}
