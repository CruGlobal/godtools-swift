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

final class UITestsAppConfig: AppConfigInterface {
    
    init() {
        
    }
    
    var analyticsEnabled: Bool {
        return false
    }
    
    var buildConfig: AppBuildConfiguration {
        return .production
    }
    
    var dynalinkClientApiKey: String? {
        return nil
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
        return false
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
        return GodToolsAppConfig.getMobileContentApiBaseUrlByScheme(environment: environment)
    }
    
    func getMobileContentCDNBaseUrl() -> String {
        return GodToolsAppConfig.getMobileContentCDNBaseUrl(environment: environment)
    }
    
    func getRealmDatabaseConfig() throws -> RealmDatabaseConfig {
        return try UITestsRealmDatabase.getRealmDatabaseConfig()
    }
    
    @available(iOS 17.4, *)
    func getSwiftDatabase() throws -> SwiftDatabase? {
        
        // TODO: Return database once SwiftDatabase can be enabled. ~Levi
        return nil
        
//        return SwiftDatabase(
//            container: try SwiftDataContainer.createInMemoryContainer(
//                schema: Schema(versionedSchema: LatestProductionSwiftDataSchema.self)
//            )
//        )
    }
    
    func getTractRemoteShareConnectionUrl() -> String {
        return GodToolsAppConfig.getTractRemoteShareWebSocketUrl(environment: environment)
    }
    
    func getUserDefaultsCache() -> UserDefaultsCacheInterface {
        return InMemUserDefaultsCache()
    }
}
