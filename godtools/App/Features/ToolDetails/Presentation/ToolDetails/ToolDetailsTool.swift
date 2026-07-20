//
//  ToolDetailsTool.swift
//  godtools
//
//  Created by Levi Eggert on 7/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct ToolDetailsTool {
    
    let appLanguage: AppLanguageDomainModel
    let toolId: String
    let primaryLanguage: AppLanguageDomainModel
    let parallelLanguage: AppLanguageDomainModel?
    let selectedLanguageIndex: Int?
    
    init(
        appLanguage: AppLanguageDomainModel,
        toolId: String,
        primaryLanguage: AppLanguageDomainModel?,
        parallelLanguage: AppLanguageDomainModel?,
        selectedLanguageIndex: Int?
    ) {
        
        self.appLanguage = appLanguage
        self.toolId = toolId
        self.primaryLanguage = primaryLanguage ?? appLanguage
        self.parallelLanguage = parallelLanguage != primaryLanguage ? parallelLanguage : nil
        self.selectedLanguageIndex = selectedLanguageIndex
    }
    
    func copy(
        toolId: String? = nil
    ) -> ToolDetailsTool {
        
        return ToolDetailsTool(
            appLanguage: appLanguage,
            toolId: toolId ?? self.toolId,
            primaryLanguage: primaryLanguage,
            parallelLanguage: parallelLanguage,
            selectedLanguageIndex: selectedLanguageIndex
        )
    }
}
