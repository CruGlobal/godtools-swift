//
//  Array+ResourceModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

extension Array where Element == ResourceModel {
    
    func filterForToolTypes(andFilteredBy additionalFilter: ResourceFilter? = nil) -> [ResourceModel] {
        return self.filter { resource in
            
            if let additionalFilter = additionalFilter, additionalFilter(resource) == false {
                return false
            }
            
            return resource.isToolType && resource.isHidden == false
        }
    }
    
    func filterForLessonTypes(andFilteredBy additionalFilter: ResourceFilter? = nil) -> [ResourceModel] {
        return self.filter { resource in
            
            if let additionalFilter = additionalFilter, additionalFilter(resource) == false {
                return false
            }
            
            return resource.isLessonType && resource.isHidden == false
        }
    }
    
    func sortedByDefaultOrder() -> [ResourceModel] {
        return self.sorted(by: { $0.attrDefaultOrder < $1.attrDefaultOrder })
    }
    
    func sortedByPrimaryLanguageAvailable(languageSettingsService: LanguageSettingsService, dataDownloader: InitialDataDownloader) -> [ResourceModel] {
        guard let primaryLanguageId = languageSettingsService.primaryLanguage.value?.id else { return self }
        
        return self.sorted(by: { resource1, resource2 in
                        
            func resourceHasTranslation(_ resource: ResourceModel) -> Bool {
                return dataDownloader.resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageId: primaryLanguageId) != nil
            }
            
            func isInDefaultOrder() -> Bool {
                return resource1.attrDefaultOrder < resource2.attrDefaultOrder
            }
            
            if resourceHasTranslation(resource1) {
                
                if resourceHasTranslation(resource2) {
                    return isInDefaultOrder()
                    
                } else {
                    return true
                }
                
            } else if resourceHasTranslation(resource2) {

                return false
                
            } else {
                return isInDefaultOrder()
            }
        })
    }
}
