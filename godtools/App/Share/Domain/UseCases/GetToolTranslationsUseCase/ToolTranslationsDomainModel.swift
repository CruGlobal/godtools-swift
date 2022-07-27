//
//  ToolTranslationsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ToolTranslationsDomainModel {
    
    let tool: ResourceModel
    let languageTranslationManifests: [MobileContentRendererLanguageTranslationManifest]
    
    init(tool: ResourceModel, languageTranslationManifests: [MobileContentRendererLanguageTranslationManifest]) {
        
        self.tool = tool
        self.languageTranslationManifests = languageTranslationManifests
    }
}
