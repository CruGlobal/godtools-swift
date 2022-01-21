//
//  GetToolTranslationManifestsFromCacheResult.swift
//  godtools
//
//  Created by Levi Eggert on 1/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetToolTranslationManifestsFromCacheResult {
    
    let toolTranslations: [ToolTranslationData]
    let translationIdsNeededDownloading: [String]
    
    required init(toolTranslations: [ToolTranslationData], translationIdsNeededDownloading: [String]) {
        
        self.toolTranslations = toolTranslations
        self.translationIdsNeededDownloading = translationIdsNeededDownloading
    }
}
