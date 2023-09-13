//
//  ToolFilterLanguageSelectionViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolFilterLanguageSelectionViewModel: ToolFilterSelectionViewModel {
        
    override init(toolFilterSelection: ToolFilterSelection, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase) {
        
        super.init(toolFilterSelection: toolFilterSelection, localizationServices: localizationServices, getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase)
        
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (primaryLanguage: LanguageDomainModel?) in
                
                let primaryLocaleId: String? = primaryLanguage?.localeIdentifier

                self?.navTitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: primaryLocaleId, key: ToolStringKeys.ToolFilter.languageFilterNavTitle.rawValue)
            }
            .store(in: &cancellables)
    }
}
