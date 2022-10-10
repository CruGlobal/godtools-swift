//
//  AppConfig.swift
//  godtools
//
//  Created by Levi Eggert on 2/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AppConfig {
    
    private static let appleAppId: String = "542773210"
    
    private let appBuild: AppBuild
    
    init(appBuild: AppBuild) {
        
        self.appBuild = appBuild
    }
    
    var appsFlyerConfiguration: AppsFlyerConfiguration {
            
            return AppsFlyerConfiguration(
                appleAppId: AppConfig.appleAppId,
                appsFlyerDevKey: "QdbVaVHi9bHRchUTWtoaij",
                shouldUseUninstallSandbox: appBuild.isDebug
            )
        }
    
    var mobileContentApiBaseUrl: String {
        
        let stagingUrl: String = "https://mobile-content-api-stage.cru.org"
        let productionUrl: String = "https://mobile-content-api.cru.org"
        
        switch appBuild.configuration {
            
        case .analyticsLogging:
            return productionUrl
        case .staging:
            return stagingUrl
        case .production:
            return productionUrl
        case .release:
            return productionUrl
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
        
        let debugFileName: String = "GoogleService-Info-Debug"
        let productionFileName: String = "GoogleService-Info"
        
        switch appBuild.configuration {
            
        case .analyticsLogging:
            return productionFileName
        case .staging:
            return debugFileName
        case .production:
            return productionFileName
        case .release:
            return productionFileName
        }
    }
    
    var snowplowAppId: String {
        
        return appBuild.isDebug ? "godtools-dev" : "godtools"
    }
}
