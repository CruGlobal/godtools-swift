//
//  ParsedDeepLinkType+DashboardTab.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

extension ParsedDeepLinkType {
    
    @MainActor var dashboardTab: DashboardTabTypeDomainModel {
        
        let defaultTab: DashboardTabTypeDomainModel = DashboardFlow.startingTab
        
        switch self {
            
        case .allToolsList:
            return .tools
        case .appLanguagesList:
            return defaultTab
        case .articleAemUri( _):
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
        case .onboarding( _):
            return defaultTab
        case .tool( _):
            return defaultTab
        case .toolDetails:
            return defaultTab
        case .tutorial:
            return defaultTab
        }
    }
}
