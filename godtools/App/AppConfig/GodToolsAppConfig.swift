//
//  GodToolsAppConfig.swift
//  godtools
//
//  Created by Levi Eggert on 8/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SocialAuthentication

class GodToolsAppConfig: AppConfigInterface {
    
    private let appBuild: AppBuild
        
    init() {
        
        appBuild = AppBuild(buildConfiguration: InfoPlist().getAppBuildConfiguration())
    }
    
    var analyticsEnabled: Bool {
        return true
    }
    
    var buildConfig: AppBuildConfiguration {
        return appBuild.configuration
    }
    
    var environment: AppEnvironment {
        return appBuild.environment
    }
    
    var firebaseEnabled: Bool {
        return true
    }
    
    var isDebug: Bool {
        return appBuild.isDebug
    }
    
    func getAppleAppId() -> String {
        return "542773210"
    }
    
    var urlRequestsEnabled: Bool {
        return true
    }
        
    func getFacebookConfiguration() -> FacebookConfiguration? {
        
        // NOTE: Currently staging isn't supported because the facebook app id is also configured in the Info.plist which is only supporting a single fb app id. ~Levi
        // staging
        /*
        return FacebookConfiguration(
            appId: "448969905944197",
            clientToken: "be1edf48d86ed54a24951ededa62eda2",
            displayName: "GodTools-Staging",
            isAutoLogAppEventsEnabled: true,
            isAdvertiserIDCollectionEnabled: false,
            isSKAdNetworkReportEnabled: false
        )*/
        
        // production
        return FacebookConfiguration(
            appId: "2236701616451487",
            clientToken: "3b6bf5b7c128a970337c4fa1860ffa6e",
            displayName: "GodTools",
            isAutoLogAppEventsEnabled: true,
            isAdvertiserIDCollectionEnabled: false,
            isSKAdNetworkReportEnabled: false
        )
    }
    
    func getFirebaseGoogleServiceFileName() -> String {
        
        switch appBuild.environment {
        
        case .staging:
            return "GoogleService-Info-Debug"
        case .production:
            return "GoogleService-Info"
        }
    }
    
    func getGoogleAuthenticationConfiguration() -> GoogleAuthenticationConfiguration? {
        
        let clientId: String
        let serverClientId: String
        
        switch environment {
        
        case .staging:
            clientId = "71275134527-st5s63prkvuh46t7ohb1gmhq39qokh78.apps.googleusercontent.com"
            serverClientId = "71275134527-nvu2ehje1j6g459ofg5aldn1n21fadpg.apps.googleusercontent.com"
            
        case .production:
            clientId = "71275134527-4stabhk838h3jpkt9mfrt1r8tisaj9r1.apps.googleusercontent.com"
            serverClientId = "71275134527-h5adpeeefcevhhhng1ggi5ngn6ko6d3k.apps.googleusercontent.com"
        }
        
        return GoogleAuthenticationConfiguration(clientId: clientId, serverClientId: serverClientId, hostedDomain: nil, openIDRealm: nil)
    }
    
    func getMobileContentApiBaseUrl() -> String {
        return Self.getMobileContentApiBaseUrlByScheme(environment: environment)
    }
    
    func getRealmDatabase() -> LegacyRealmDatabase {
        
        switch appBuild.environment {
        
        case .staging:
            return LegacyRealmDatabase(databaseConfiguration: RealmDatabaseStagingConfiguration())
        case .production:
            return LegacyRealmDatabase(databaseConfiguration: RealmDatabaseProductionConfiguration())
        }
    }
    
    func getTractRemoteShareConnectionUrl() -> String {
        return Self.getTractRemoteShareWebSocketUrl(environment: environment)
    }
}

extension GodToolsAppConfig {
    
    static func getMobileContentApiBaseUrlByScheme(environment: AppEnvironment, scheme: String = "https") -> String {
        
        switch environment {
        
        case .staging:
            return "\(scheme)://mobile-content-api-stage.cru.org"
        case .production:
            return "\(scheme)://mobile-content-api.cru.org"
        }
    }
    
    static func getTractRemoteShareWebSocketUrl(environment: AppEnvironment) -> String {
        
        return Self.getMobileContentApiBaseUrlByScheme(environment: environment, scheme: "wss") + "/" + "cable"
    }
}
