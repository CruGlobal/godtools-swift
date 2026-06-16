//
//  ToolNavigation.swift
//  godtools
//
//  Created by Levi Eggert on 6/11/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct ToolNavigation {
    
    let appLanguage: AppLanguageDomainModel
    let liveShareStream: String?
    let selectedLanguageIndex: Int?
    let trainingTipsEnabled: Bool
    let initialPage: MobileContentRendererInitialPage?
    let initialPageSubIndex: Int?
    let toolOpenedFrom: ToolOpenedFrom
    let persistToolLanguageSettings: PersistToolLanguageSettingsInterface?
    
    func copy(initialPage: MobileContentRendererInitialPage? = nil) -> ToolNavigation {
        
        return ToolNavigation(
            appLanguage: appLanguage,
            liveShareStream: liveShareStream,
            selectedLanguageIndex: selectedLanguageIndex,
            trainingTipsEnabled: trainingTipsEnabled,
            initialPage: initialPage ?? self.initialPage,
            initialPageSubIndex: initialPageSubIndex,
            toolOpenedFrom: toolOpenedFrom,
            persistToolLanguageSettings: persistToolLanguageSettings
        )
    }
}
