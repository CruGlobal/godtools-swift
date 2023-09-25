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
    
    private let getToolFilterLanguagesUseCase: GetToolFilterLanguagesUseCase
    
    private var languages: [LanguageFilterDomainModel] = [LanguageFilterDomainModel]()
    
    init(getToolFilterLanguagesUseCase: GetToolFilterLanguagesUseCase, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, toolFilterSelectionPublisher: CurrentValueSubject<ToolFilterSelection, Never>) {
        
        self.getToolFilterLanguagesUseCase = getToolFilterLanguagesUseCase
        
        super.init(localizationServices: localizationServices, getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase, toolFilterSelectionPublisher: toolFilterSelectionPublisher)
        
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (primaryLanguage: LanguageDomainModel?) in
                
                let primaryLocaleId: String? = primaryLanguage?.localeIdentifier

                self?.navTitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: primaryLocaleId, key: ToolStringKeys.ToolFilter.languageFilterNavTitle.rawValue)
            }
            .store(in: &cancellables)
        
        getToolFilterLanguagesUseCase.getToolFilterLanguagesPublisher(filteredByCategory: selectedCategory)
            .sink { [weak self] languages in
                
                self?.languages = languages
                self?.createRowViewModels()
            }
            .store(in: &cancellables)
        
        searchTextPublisher
            .sink { [weak self] searchText in
                
                self?.createRowViewModels()
            }
            .store(in: &cancellables)
        
        filterValueSelected = .language(languageModel: selectedLanguage)
    }
}

// MARK: - Private

extension ToolFilterLanguageSelectionViewModel {
    
    private func createRowViewModels() {
        
        let languages: [LanguageFilterDomainModel]
        let searchText = searchTextPublisher.value
        
        if searchText.isEmpty == false {
            
            languages = self.languages.filter { $0.searchableText.contains(searchText) }
        } else {
            
            languages = self.languages
        }
        
        rowViewModels = languages.map { language in
            
            return ToolFilterSelectionRowViewModel(
                title: language.languageName,
                subtitle: language.translatedName,
                toolsAvailableText: language.toolsAvailableText,
                filterValue: .language(languageModel: language)
            )
        }
    }
}
