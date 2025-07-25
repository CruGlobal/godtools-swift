//
//  InfoPlist+AppBuildConfiguration.swift
//  godtools
//
//  Created by Levi Eggert on 7/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

extension InfoPlist {
    
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
