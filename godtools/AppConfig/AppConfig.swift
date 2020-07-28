//
//  AppConfig.swift
//  godtools
//
//  Created by Levi Eggert on 2/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AppConfig: ConfigType {
    
    let isDebug: Bool
    let appleAppId: String
    
    required init() {
        
        // RELEASE and DEBUG flags need to be set under Build Settings > Other Swift Flags.  Add -DDEBUG for debug builds and -DRELEASE for release builds.
        #if RELEASE
            isDebug = false
        #elseif DEBUG
            isDebug = true
        #else
            isDebug = false
            assertionFailure("In ( Build Settings > Other Swift Flags ) set either -DDEBUG or -DRELEASE for each scheme.")
        #endif
        
        appleAppId = "542773210"
    }
    
    var build: AppBuild {
        
        if !isDebug {
            return .release
        }
        else if let build = AppBuild(rawValue: configuration.lowercased()) {
            return build
        }
        else if isDebug {
            return.staging
        }
        else {
            return .release
        }
    }
    
    var versionLabel: String {
        if isDebug {
            return "v" + appVersion + " " + "(" + bundleVersion + ")"
        }
        else {
            return "v" + appVersion
        }
    }
    
    var mobileContentApiBaseUrl: String {
        
        let stagingUrl: String = "https://mobile-content-api-stage.cru.org"
        let productionUrl: String = "https://mobile-content-api.cru.org"
        
        switch build {
            
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
        
        switch build {
        case .staging:
            return debugFileName
        case .production:
            return productionFileName
        case .release:
            return productionFileName
        }
    }
    
    var snowplowAppId: String {
        
        let debugAppId: String = "godtools-dev"
        let productionAppId: String = "godtools"

        if isDebug {
            return debugAppId
        }
        else {
            return productionAppId
        }
    }
    
    // MARK: - Info.plist
    
    private var info: [String: Any] {
        return Bundle.main.infoDictionary ?? [:]
    }
    
    private var displayName: String {
        return info["CFBundleDisplayName"] as? String ?? ""
    }
    
    private var appVersion: String {
        return info["CFBundleShortVersionString"] as? String ?? ""
    }
    
    private var bundleIdentifier: String {
        return info["CFBundleIdentifier"] as? String ?? ""
    }
    
    private var bundleVersion: String {
        return info["CFBundleVersion"] as? String ?? ""
    }
    
    private var configuration: String {
        return info["Configuration"] as? String ?? ""
    }
    
    // MARK: - Log
    
    func logConfiguration() {
        if isDebug {
            print("AppConfig")
            print("  build: \(build)")
            print("  configuration: \(configuration)")
            print("  isDebug: \(isDebug)")
            print("  displayName: \(displayName)")
            print("  appVersion: \(appVersion)")
            print("  bundleVersion: \(bundleVersion)")
            print("  mobileContentApiBaseUrl: \(mobileContentApiBaseUrl)")
            print("  appsFlyerDevKey: \(appsFlyerDevKey)")
            print("  googleAdwordsLabel: \(googleAdwordsLabel)")
            print("  googleAdwordsConversionId: \(googleAdwordsConversionId)")
            print("  firebaseGoogleServiceFileName: \(firebaseGoogleServiceFileName)")
            print("")
        }
    }
}
