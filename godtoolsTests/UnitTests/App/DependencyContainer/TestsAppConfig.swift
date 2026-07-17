//
//  TestsAppConfig.swift
//  godtools
//
//  Created by Levi Eggert on 8/23/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SocialAuthentication
@testable import godtools
import RepositorySync
import SwiftData

final class TestsAppConfig: AppConfigInterface {
    
    private let realmDatabase: RealmDatabase?
    private let swiftDatabase: Any?

    init(realmDatabase: RealmDatabase? = nil, swiftDatabase: Any? = nil) {
        self.realmDatabase = realmDatabase
        self.swiftDatabase = swiftDatabase
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
    
    func getAppleAppId() -> String {
        return ""
    }
    
    var urlRequestsEnabled: Bool {
        return false
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
        return getMobileContentApiBaseUrlByScheme()
    }
    
    func getMobileContentCDNBaseUrl() -> String {
        return GodToolsAppConfig.getMobileContentCDNBaseUrl(environment: .production)
    }
    
    private func getMobileContentApiBaseUrlByScheme(scheme: String = "https") -> String {
        return "\(scheme)://mobile-content-api.cru.org"
    }
    
    func getRealmDatabase() throws -> RealmDatabase {
        guard let realmDatabase = realmDatabase else {
            return RealmDatabase(
                databaseConfig: try RealmDatabaseConfig.createInMemoryConfig()
            )
        }
        return realmDatabase
    }
    
    @available(iOS 17.4, *)
    func getSwiftDatabase() throws -> SwiftDatabase? {
        return swiftDatabase as? SwiftDatabase
    }
    
    func getTractRemoteShareConnectionUrl() -> String {
        return getMobileContentApiBaseUrlByScheme(scheme: "wss") + "/" + "cable"
    }
    
    func getUserDefaultsCache() -> UserDefaultsCacheInterface {
        return InMemUserDefaultsCache()
    }
}

