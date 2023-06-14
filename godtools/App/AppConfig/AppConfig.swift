//
//  AppConfig.swift
//  godtools
//
//  Created by Levi Eggert on 2/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SocialAuthentication

class AppConfig {
        
    private let appBuild: AppBuild
    
    let appleAppId: String = "542773210"
    let facebookConfig: FacebookConfiguration
    let googleAuthenticationConfiguration: GoogleAuthenticationConfiguration
    
    init(appBuild: AppBuild) {
        
        self.appBuild = appBuild
        
        facebookConfig = FacebookConfiguration(
            appId: "2236701616451487",
            clientToken: "3b6bf5b7c128a970337c4fa1860ffa6e",
            displayName: "GodTools",
            isAutoLogAppEventsEnabled: true,
            isAdvertiserTrackingEnabled: false,
            isAdvertiserIDCollectionEnabled: false,
            isSKAdNetworkReportEnabled: false
        )
        
        googleAuthenticationConfiguration = AppConfig.getGoogleAuthenticationConfiguration(environment: appBuild.environment)
    }
    
    private static func getGoogleAuthenticationConfiguration(environment: AppEnvironment) -> GoogleAuthenticationConfiguration {
                        
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
    
    var appsFlyerConfiguration: AppsFlyerConfiguration {
            
            return AppsFlyerConfiguration(
                appleAppId: appleAppId,
                appsFlyerDevKey: "QdbVaVHi9bHRchUTWtoaij",
                shouldUseUninstallSandbox: appBuild.isDebug
            )
        }
    
    var mobileContentApiBaseUrl: String {
        
        switch appBuild.environment {
        
        case .staging:
            return "https://mobile-content-api-stage.cru.org"
        case .production:
            return "https://mobile-content-api.cru.org"
        }
    }
    
    var tractRemoteShareConnectionUrl: String {
        
        return mobileContentApiBaseUrl + "/" + "cable"
    }
    
    var appsFlyerDevKey: String {
        return "QdbVaVHi9bHRchUTWtoaij"
    }
    
    var googleAdwordsLabel: String {
        return "872849633"
    }
    
    var googleAdwordsConversionId: String {
        return "uYJUCLG6tmoQ4cGaoAM"
    }
    
    var firebaseGoogleServiceFileName: String {
        
        switch appBuild.environment {
        
        case .staging:
            return "GoogleService-Info-Debug"
        case .production:
            return "GoogleService-Info"
        }
    }
}
