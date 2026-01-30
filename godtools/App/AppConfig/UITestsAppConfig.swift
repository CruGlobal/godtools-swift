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
        return UITestsRealmDatabase()
    }
    
    func getRealmDatabase() -> RealmDatabase {
        return RealmDatabase(databaseConfig: RealmDatabaseConfig.createInMemoryConfig())
    }
    
    @available(iOS 17.4, *)
    func getSwiftDatabase() throws -> SwiftDatabase? {
       
        return nil
        
        // TODO: Return database once SwiftDatabase can be enabled. ~Levi
        
        /*
        
        let database = SwiftDatabase(
            container: try SwiftDataContainer.createInMemoryContainer(
                name: "godtools_swiftdata_ui_tests",
                schema: Schema(versionedSchema: LatestProductionSwiftDataSchema.self)
            )
        )
        
        return database*/
    }
    
    func getTractRemoteShareConnectionUrl() -> String {
        return GodToolsAppConfig.getTractRemoteShareWebSocketUrl(environment: environment)
    }
}
