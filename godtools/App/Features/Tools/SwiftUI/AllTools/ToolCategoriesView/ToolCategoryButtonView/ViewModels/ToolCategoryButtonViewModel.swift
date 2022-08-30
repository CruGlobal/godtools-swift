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
    
    let category: ToolCategoryDomainModel
    let localizationServices: LocalizationServices
    let languageSettingsService: LanguageSettingsService
        
    // MARK: - Init
    
    init(category: ToolCategoryDomainModel, selectedAttrCategory: String?, localizationServices: LocalizationServices, languageSettingsService: LanguageSettingsService) {
        self.category = category
        self.localizationServices = localizationServices
        self.languageSettingsService = languageSettingsService
        
        let bundle = localizationServices.bundleLoader.bundleForPrimaryLanguageOrFallback(in: languageSettingsService)
        let translatedCategory = localizationServices.toolCategoryStringForBundle(bundle: bundle, attrCategory: category.category)
        
        let buttonState = ToolCategoryButtonState(category: category.category, selectedCategory: selectedAttrCategory)
        
        super.init(categoryText: translatedCategory, buttonState: buttonState)                
    }

    // MARK: - Overrides
    
    override func updateStateWithSelectedCategory(_ selectedAttrCategory: String?) {
        let buttonState = ToolCategoryButtonState(category: category.category, selectedCategory: selectedAttrCategory)
        
        setButtonState(buttonState)
    }
}
