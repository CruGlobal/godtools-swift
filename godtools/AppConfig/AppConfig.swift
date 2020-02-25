//
//  AppConfig.swift
//  godtools
//
//  Created by Levi Eggert on 2/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct AppConfig: ConfigType {
    
    let isDebug: Bool
    let appleAppId: String
    
    init() {
        
        #if RELEASE
            isDebug = false
        #else
            isDebug = true
        #endif
        
        appleAppId = "542773210"
    }
    
    var build: AppBuild {
        if let build = AppBuild(rawValue: configuration.lowercased()) {
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
    
    var appsFlyerDevKey: String {
        return "QdbVaVHi9bHRchUTWtoaij"
    }
    
    var mobileContentApiBaseUrl: String {
        
        switch build {
            
        case .staging:
            return "https://mobile-content-api-stage.cru.org"
        case .production:
            return "https://mobile-content-api.cru.org"
        case .release:
            return "https://mobile-content-api.cru.org"
        }
    }
    
    func logConfiguration() {
        if isDebug {
            print("AppConfig")
            print("  isDebug: \(isDebug)")
            print("  displayName: \(displayName)")
            print("  appVersion: \(appVersion)")
            print("  bundleVersion: \(bundleVersion)")
            print("  configuration: \(configuration)")
            print("  build: \(build)")
            print("  mobileContentApiBaseUrl: \(mobileContentApiBaseUrl)")
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
}
