//
//  ResourcesCacheTests.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import RealmSwift
import SwiftData

struct ResourcesCacheTests {
    
}

extension ResourcesCacheTests {
    
    private func getResourcesCache(swiftPersistenceIsEnabled: Bool) -> ResourcesCache {
        
        if #available(iOS 17.4, *), swiftPersistenceIsEnabled {
            TempSharedSwiftDatabase.shared.setDatabase(
                swiftDatabase: getSwiftDatabase()
            )
        }
        
        let realmDatabase: RealmDatabase = getRealmDatabase()
        
        let trackDownloadedTranslationsRepository = TrackDownloadedTranslationsRepository(
            cache: TrackDownloadedTranslationsCache(
                realmDatabase: realmDatabase
            )
        )
        
        return ResourcesCache(
            realmDatabase: realmDatabase,
            trackDownloadedTranslationsRepository: trackDownloadedTranslationsRepository,
            swiftPersistenceIsEnabled: swiftPersistenceIsEnabled
        )
    }
}

// MARK: - RealmDatabase

extension ResourcesCacheTests {
    
    private func getRealmResources() -> [RealmResource] {
        
        return Array()
    }
    
    private func getRealmDatabaseObjects() -> [Object] {
        return Array()
    }
    
    private func getRealmDatabase() -> RealmDatabase {
        return TestsInMemoryRealmDatabase(
            addObjectsToDatabase: getRealmDatabaseObjects()
        )
    }
}

// MARK: - SwiftDatabase

extension ResourcesCacheTests {
    
    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [any IdentifiableSwiftDataObject] {
        return Array()
    }
    
    @available(iOS 17.4, *)
    private func getSwiftDatabase() -> SwiftDatabase {
        return TestsInMemorySwiftDatabase(
            addObjectsToDatabase: getSwiftDatabaseObjects()
        )
    }
}
