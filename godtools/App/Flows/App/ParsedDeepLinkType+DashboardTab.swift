//
//  ParsedDeepLinkType+DashboardTab.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

extension ParsedDeepLinkType {
    
    var dashboardTab: DashboardTabTypeDomainModel {
        
        let defaultTab: DashboardTabTypeDomainModel = DashboardFlow.startingTab
        
        switch self {
            
        case .allToolsList:
            return .tools
        case .appLanguagesList:
            return defaultTab
        case .articleAemUri(aemUri: let aemUri):
            return defaultTab
        case .dashboard:
            return defaultTab
        case .favoritedToolsList:
            return defaultTab
        case .languageSettings:
            return defaultTab
        case .localizationSettings:
            return defaultTab
        case .lessonsList:
            return .lessons
        case .menu:
            return defaultTab
        case .onboarding(appLanguage: let appLanguage):
            return defaultTab
        case .tool(toolDeepLink: let toolDeepLink):
            return defaultTab
        case .tutorial:
            return defaultTab
        }
    }
}
