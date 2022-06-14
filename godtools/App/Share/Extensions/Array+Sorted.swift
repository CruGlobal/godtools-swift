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
        guard let primaryLanguageId = languageSettingsService.primaryLanguage.value?.id else { return self }
        
        return self.sorted(by: { resource1, resource2 in
                        
            func resourceHasTranslation(_ resource: ResourceModel) -> Bool {
                return dataDownloader.resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageId: primaryLanguageId) != nil
            }
            
            func isSortedByDefaultOrder() -> Bool {
                return resource1.attrDefaultOrder < resource2.attrDefaultOrder
            }
            
            if resourceHasTranslation(resource1) {
                
                if resourceHasTranslation(resource2) {
                    return isSortedByDefaultOrder()
                    
                } else {
                    return true
                }
                
            } else if resourceHasTranslation(resource2) {

                return false
                
            } else {
                return isSortedByDefaultOrder()
            }
        })
    }
}
