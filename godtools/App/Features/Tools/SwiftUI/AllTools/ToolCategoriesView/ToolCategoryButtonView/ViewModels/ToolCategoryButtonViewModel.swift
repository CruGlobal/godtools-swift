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
    private let localizationServices: LocalizationServices
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
        
    // MARK: - Init
    
    init(category: ToolCategoryDomainModel, selectedCategoryName: String?, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase) {
        self.category = category
        self.localizationServices = localizationServices
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        
        let bundle: Bundle
        if let primaryLanguage = getSettingsPrimaryLanguageUseCase.getPrimaryLanguage() {
            
            bundle = localizationServices.bundleLoader.bundleForResource(resourceName: primaryLanguage.localeIdentifier) ?? Bundle.main
            
        } else {
            
            bundle = localizationServices.bundleLoader.englishBundle ?? Bundle.main
        }

        let translatedCategory = localizationServices.toolCategoryStringForBundle(bundle: bundle, attrCategory: category.categoryName)
        
        let buttonState = ToolCategoryButtonState(category: category.categoryName, selectedCategory: selectedCategoryName)
        
        super.init(categoryText: translatedCategory, buttonState: buttonState)                
    }

    // MARK: - Overrides
    
    override func updateStateWithSelectedCategory(_ selectedCategoryName: String?) {
        let buttonState = ToolCategoryButtonState(category: category.categoryName, selectedCategory: selectedCategoryName)
        
        setButtonState(buttonState)
    }
}
