//
//  ToolStringKeys.swift
//  godtools
//
//  Created by Rachael Skeath on 9/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolStringKeys {
    
    enum Spotlight: String {
        case title = "allTools.spotlight.title"
        case subtitle = "allTools.spotlight.description"
    }
    
    enum ToolFilter: String {
        case filterSectionTitle = "allTools.filter.title"
        case anyCategoryFilterText = "allTools.filter.anyCategory"
        case anyLanguageFilterText = "allTools.filter.anyLanguage"
        case categoryFilterNavTitle = "allTools.filter.navBar.category"
        case languageFilterNavTitle = "allTools.filter.navBar.language"
        case toolsAvailableText = "tools.filter.toolsAvailable"
    }
}
