//
//  GetToolTranslationsFromCacheResult.swift
//  godtools
//
//  Created by Levi Eggert on 1/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetToolTranslationsFromCacheResult {
    
    let toolTranslations: [ToolTranslation]
    let translationIdsNeededDownloading: [String]
    
    required init(toolTranslations: [ToolTranslation], translationIdsNeededDownloading: [String]) {
        
        self.toolTranslations = toolTranslations
        self.translationIdsNeededDownloading = translationIdsNeededDownloading
    }
}
