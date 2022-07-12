//
//  AllToolsCategoryButtonViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AllToolsCategoryButtonViewModel: BaseToolCategoryButtonViewModel {
    
    init(selectedAttrCategory: String?, localizationServices: LocalizationServices, languageSettingsService: LanguageSettingsService) {
        
        let bundle = localizationServices.bundleLoader.bundleForPrimaryLanguageOrFallback(in: languageSettingsService)
        let translatedAllToolsText = localizationServices.stringForBundle(bundle: bundle, key: "find_tools")
        
        let buttonState = ToolCategoryButtonState(category: nil, selectedCategory: selectedAttrCategory)
        
        super.init(categoryText: translatedAllToolsText, buttonState: buttonState)
    }
    
    override func updateStateWithSelectedCategory(_ selectedAttrCategory: String?) {
        
        let buttonState = ToolCategoryButtonState(category: nil, selectedCategory: selectedAttrCategory)
        
        setButtonState(buttonState)
    }
}
