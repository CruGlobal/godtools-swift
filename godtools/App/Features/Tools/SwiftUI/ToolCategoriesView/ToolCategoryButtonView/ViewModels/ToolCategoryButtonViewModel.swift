//
//  ToolCategoryButtonViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/19/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ToolCategoryButtonViewModel: BaseToolCategoryButtonViewModel {
    
    // MARK: - Properties
    
    let attrCategory: String
    let localizationServices: LocalizationServices
    let languageSettingsService: LanguageSettingsService
        
    // MARK: - Init
    
    init(attrCategory: String, selectedAttrCategory: String?, localizationServices: LocalizationServices, languageSettingsService: LanguageSettingsService) {
        self.attrCategory = attrCategory
        self.localizationServices = localizationServices
        self.languageSettingsService = languageSettingsService
        
        let bundle = localizationServices.bundleLoader.bundleForPrimaryLanguageOrFallback(in: languageSettingsService)
        let translatedCategory = localizationServices.toolCategoryStringForBundle(bundle: bundle, attrCategory: attrCategory)
        
        let buttonState = ToolCategoryButtonState(category: attrCategory, selectedCategory: selectedAttrCategory)
        
        super.init(categoryText: translatedCategory, buttonState: buttonState)                
    }
}

// MARK: - Public

extension ToolCategoryButtonViewModel {
    func updateStateWithSelectedCategory(_ selectedAttrCategory: String?) {
        state = ToolCategoryButtonState(category: attrCategory, selectedCategory: selectedAttrCategory)
        
        setPublishedValues()
    }
}
