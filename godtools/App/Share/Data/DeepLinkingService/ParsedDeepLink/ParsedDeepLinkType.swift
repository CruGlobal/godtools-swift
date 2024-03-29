//
//  ParsedDeepLinkType.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

enum ParsedDeepLinkType: Equatable {
    
    case allToolsList
    case appLanguagesList
    case articleAemUri(aemUri: String)
    case dashboard
    case favoritedToolsList
    case languageSettings
    case lessonsList
    case onboarding(appLanguage: AppLanguageDomainModel)
    case tool(toolDeepLink: ToolDeepLink)
}
