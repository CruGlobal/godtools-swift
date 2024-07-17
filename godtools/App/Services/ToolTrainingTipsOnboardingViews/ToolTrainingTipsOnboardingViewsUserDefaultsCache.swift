//
//  ToolTrainingTipsOnboardingViewsUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 10/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ToolTrainingTipsOnboardingViewsUserDefaultsCache {
    
    private let userDefaultsCache: SharedUserDefaultsCache
    private let getTranslatedToolName: GetTranslatedToolName
    
    init(userDefaultsCache: SharedUserDefaultsCache, getTranslatedToolName: GetTranslatedToolName) {
        
        self.userDefaultsCache = userDefaultsCache
        self.getTranslatedToolName = getTranslatedToolName
    }
    
    private func getNumberOfViewsKey(toolId: String, primaryLanguage: AppLanguageDomainModel) -> String {
        
        let toolName: String = getTranslatedToolName.getToolName(toolId: toolId, translateInLanguage: primaryLanguage)
        
        return "ToolTrainingTipsOnboardingViewsService." + toolName + "_" + toolId
    }
    
    func getNumberOfToolTrainingTipViews(toolId: String, primaryLanguage: AppLanguageDomainModel) -> Int {
        
        if let number = userDefaultsCache.getValue(key: getNumberOfViewsKey(toolId: toolId, primaryLanguage: primaryLanguage)) as? NSNumber {
            return number.intValue
        }
        
        return 0
    }
    
    func storeToolTrainingTipViewed(toolId: String, primaryLanguage: AppLanguageDomainModel) {
        
        let numberOfViews: Int = getNumberOfToolTrainingTipViews(toolId: toolId, primaryLanguage: primaryLanguage)
        
        if numberOfViews < Int.max {
            
            let newNumberOfViews: Int = numberOfViews + 1
            
            userDefaultsCache.cache(
                value: NSNumber(value: newNumberOfViews),
                forKey: getNumberOfViewsKey(toolId: toolId, primaryLanguage: primaryLanguage)
            )
            
            userDefaultsCache.commitChanges()
        }
    }
}
