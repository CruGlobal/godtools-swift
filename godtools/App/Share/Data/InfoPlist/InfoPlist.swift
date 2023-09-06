//
//  InfoPlist.swift
//  godtools
//
//  Created by Levi Eggert on 9/30/22.
//  Copyright © 2022 Cru. All rights reserved.
//
import Foundation

class InfoPlist {

    let info: [String: Any]

    init() {

        info = Bundle.main.infoDictionary ?? [:]
    }

    var displayName: String? {
        return info["CFBundleDisplayName"] as? String
    }

    var appVersion: String? {
        return info["CFBundleShortVersionString"] as? String
    }

    var bundleIdentifier: String? {
        return info["CFBundleIdentifier"] as? String
    }

    var bundleVersion: String? {
        return info["CFBundleVersion"] as? String
    }

    var configuration: String? {
        return info["Configuration"] as? String
    }
    
    func getAppBuildConfiguration() -> AppBuildConfiguration? {
        
        guard let configuration = self.configuration, !configuration.isEmpty else {
            return nil
        }
        
        // Defined in godtools project > Info > Configurations Section.
        // Info plist must also contain Key: Configuration and Value: $(CONFIGURATION)
        // ~Levi
        
        switch configuration.lowercased() {
        
        case "analyticslogging":
            return .analyticsLogging
        
        case "staging":
            return .staging
        
        case "production":
            return .production
        
        case "release":
            return .release
            
        default:
            return .release
        }
    }
}
