//
//  ToolFilterLanguageSelectionViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ToolFilterLanguageSelectionViewModel: ToolFilterSelectionViewModel {
        
    override init(localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getAllToolsUseCase: GetAllToolsUseCase, toolFilterSelectionPublisher: CurrentValueSubject<ToolFilterSelection, Never>) {
        
        super.init(localizationServices: localizationServices, getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase, getAllToolsUseCase: getAllToolsUseCase, toolFilterSelectionPublisher: toolFilterSelectionPublisher)
        
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (primaryLanguage: LanguageDomainModel?) in
                
                let primaryLocaleId: String? = primaryLanguage?.localeIdentifier

                self?.navTitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: primaryLocaleId, key: ToolStringKeys.ToolFilter.languageFilterNavTitle.rawValue)
            }
            .store(in: &cancellables)
    }
}
