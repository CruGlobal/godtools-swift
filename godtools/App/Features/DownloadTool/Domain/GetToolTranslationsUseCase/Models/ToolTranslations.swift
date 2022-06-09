//
//  ToolTranslations.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ToolTranslations {
    
    let tool: ResourceModel
    let languageTranslationManifests: [MobileContentRendererLanguageTranslationManifest]
    
    init(tool: ResourceModel, languageTranslationManifests: [MobileContentRendererLanguageTranslationManifest]) {
        
        self.tool = tool
        self.languageTranslationManifests = languageTranslationManifests
    }
}

