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
    
    init(category: ToolCategoryDomainModel, selectedCategoryId: String?, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase) {
        self.category = category
        self.localizationServices = localizationServices
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        
        let buttonState = ToolCategoryButtonState(categoryId: category.id, selectedCategoryId: selectedCategoryId)
        
        super.init(categoryText: category.translatedName, buttonState: buttonState)
    }

    // MARK: - Overrides
    
    override func updateStateWithSelectedCategory(_ selectedCategoryId: String?) {
        let buttonState = ToolCategoryButtonState(categoryId: category.id, selectedCategoryId: selectedCategoryId)
        
        setButtonState(buttonState)
    }
}
