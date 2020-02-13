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
    let appVersion: String
    let bundleVersion: String
    
    init() {
        
        #if RELEASE
            isDebug = false
        #else
            isDebug = true
        #endif
        
        appleAppId = "542773210"
        appVersion = AppConfig.getInfoString(key: "CFBundleShortVersionString") ?? ""
        bundleVersion = AppConfig.getInfoString(key: "CFBundleVersion") ?? ""
    }
    
    var appsFlyerDevKey: String {
        return "QdbVaVHi9bHRchUTWtoaij"
    }
    
    var versionLabel: String {
        if isDebug {
            return "v" + appVersion + " " + "(" + bundleVersion + ")"
        }
        else {
            return "v" + appVersion
        }
    }
    
    // MARK: - Info.plist Helper
    
    private static var info: [String: Any]? {
        return Bundle.main.infoDictionary
    }
    
    private static func getInfoString(key: String) -> String? {
        if let stringValue = AppConfig.info?[key] as? String {
            return stringValue
        }
        return nil
    }
}
