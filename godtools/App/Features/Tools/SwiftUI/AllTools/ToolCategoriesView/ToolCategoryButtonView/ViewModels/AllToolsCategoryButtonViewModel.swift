//
//  AllToolsCategoryButtonViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AllToolsCategoryButtonViewModel: BaseToolCategoryButtonViewModel {
        
    init(selectedCategoryId: String?, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase) {
        
        let bundle: Bundle
        if let primaryLanguage = getSettingsPrimaryLanguageUseCase.getPrimaryLanguage() {
            
            bundle = localizationServices.bundleLoader.bundleForResource(resourceName: primaryLanguage.localeIdentifier) ?? Bundle.main
            
        } else {
            
            bundle = localizationServices.bundleLoader.englishBundle ?? Bundle.main
        }
        
        let translatedAllToolsText = localizationServices.stringForBundle(bundle: bundle, key: "find_tools")
        
        let buttonState = ToolCategoryButtonState(categoryId: nil, selectedCategoryId: selectedCategoryId)
        
        super.init(categoryText: translatedAllToolsText, buttonState: buttonState)
    }
    
    override func updateStateWithSelectedCategory(_ selectedCategoryId: String?) {
        
        let buttonState = ToolCategoryButtonState(categoryId: nil, selectedCategoryId: selectedCategoryId)
        
        setButtonState(buttonState)
    }
}
