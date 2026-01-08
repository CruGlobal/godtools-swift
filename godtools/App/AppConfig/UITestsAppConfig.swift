//
//  UITestsAppConfig.swift
//  godtools
//
//  Created by Levi Eggert on 8/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SocialAuthentication
import RepositorySync
import SwiftData

class UITestsAppConfig: AppConfigInterface {
    
    init() {
        
    }
    
    var analyticsEnabled: Bool {
        return false
    }
    
    var buildConfig: AppBuildConfiguration {
        return .production
    }
    
    var environment: AppEnvironment {
        return .production
    }
    
    var firebaseEnabled: Bool {
        return false
    }
    
    var isDebug: Bool {
        return false
    }
    
    var urlRequestsEnabled: Bool {
        return true
    }
    
    func getAppleAppId() -> String {
        return ""
    }
    
    func getFacebookConfiguration() -> FacebookConfiguration? {
        return nil
    }
    
    func getFirebaseGoogleServiceFileName() -> String {
        return ""
    }
    
    func getGoogleAuthenticationConfiguration() -> GoogleAuthenticationConfiguration? {
        return nil
    }
    
    func getMobileContentApiBaseUrl() -> String {
        return GodToolsAppConfig.getMobileContentApiBaseUrlByScheme(environment: environment, scheme: "https")
    }
    
    func getLegacyRealmDatabase() -> LegacyRealmDatabase {
        
        // TODO: Use throws on method here. ~Levi
        
        do {
            
            return try UITestsRealmDatabase().legacyRealmDatabase
        }
        catch let error {
            assertionFailure("Failed to create legacy realm database with error: \(error.localizedDescription)")
            return LegacyRealmDatabase(
                databaseConfiguration: RealmDatabaseConfiguration(cacheType: .inMemory(identifier: "legacy_realm"), schemaVersion: 1),
                realmInstanceCreationType: .usesASingleSharedRealmInstance
            )
        }
    }
    
    func getRealmDatabase() -> RealmDatabase {
        
        // TODO: Use throws on method here. ~Levi
        
        do {
            
            return try UITestsRealmDatabase().realmDatabase
        }
        catch let error {
            assertionFailure("Failed to create realm database with error: \(error.localizedDescription)")
            return RealmDatabase(databaseConfig: RealmDatabaseConfig.createInMemoryConfig())
        }
    }
    
    @available(iOS 17.4, *)
    func getSwiftDatabase() throws -> SwiftDatabase? {
       
        // TODO: Return database once SwiftDatabase can be enabled. ~Levi
        
//        let database = SwiftDatabase(
//            container: try SwiftDataContainer.createInMemoryContainer(
//                name: "godtools_swiftdata_ui_tests",
//                schema: Schema(versionedSchema: LatestProductionSwiftDataSchema.self)
//            )
//        )
        
        return nil
    }
    
    func getTractRemoteShareConnectionUrl() -> String {
        return GodToolsAppConfig.getTractRemoteShareWebSocketUrl(environment: environment)
    }
}
