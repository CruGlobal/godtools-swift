//
//  Array+Sorted.swift
//  godtools
//
//  Created by Rachael Skeath on 5/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

extension Array where Element == ResourceModel {
    
    func sortedByPrimaryLanguageAvailable(languageSettingsService: LanguageSettingsService, dataDownloader: InitialDataDownloader) -> [ResourceModel] {
        
        return self.sorted(by: { resource1, resource2 in
            
            guard let primaryLanguageId = languageSettingsService.primaryLanguage.value?.id else { return true }
            let resourcesCache = dataDownloader.resourcesCache
            
            let resource1HasTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource1.id, languageId: primaryLanguageId) != nil
            let resource2HasTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource2.id, languageId: primaryLanguageId) != nil
                
            if resource1HasTranslation {
                return true
                
            } else if resource2HasTranslation {
                return false
                
            } else {
                return true
            }
        })
    }
}
