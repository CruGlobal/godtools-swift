//
//  ToolSettingsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 5/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class ToolSettingsRepository {
    
    private let cache: RealmToolSettingsCache
    
    init(cache: RealmToolSettingsCache) {
        self.cache = cache
    }
    
    func storeToolSettings(toolId: String, primaryLanguageId: String, parallelLanguageId: String?) {
        
        let dataModel = ToolSettingsDataModel(
            toolId: toolId,
            primaryLanguageId: primaryLanguageId,
            parallelLanguageId: parallelLanguageId
        )
        
        cache.storeToolSettings(dataModel: dataModel)
    }
}
