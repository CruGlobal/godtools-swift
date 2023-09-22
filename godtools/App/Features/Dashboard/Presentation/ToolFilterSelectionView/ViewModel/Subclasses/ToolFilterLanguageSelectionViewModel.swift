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
                self?.createRowViewModels(from: languages)
            }
            .store(in: &cancellables)
        
        searchTextPublisher
            .sink { [weak self] searchText in
                guard let self = self else { return }
                
                let filteredLanguages = self.languages.filter { language in
                    
                    if searchText.isEmpty {
                        return true
                        
                    } else {
                        
                        let languageText = language.translatedName ?? language.languageName
                        return languageText.contains(searchText)
                    }
                }
                
                self.createRowViewModels(from: filteredLanguages)
            }
            .store(in: &cancellables)
        
        filterValueSelected = .language(languageModel: selectedLanguage)
    }
}

// MARK: - Private

extension ToolFilterLanguageSelectionViewModel {
    
    private func createRowViewModels(from languages: [LanguageFilterDomainModel]) {
        
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
