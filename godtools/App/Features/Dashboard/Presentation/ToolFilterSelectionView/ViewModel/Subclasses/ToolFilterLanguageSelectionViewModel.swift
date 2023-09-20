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
    
    private let getAllToolLanguagesUseCase: GetAllToolLanguagesUseCase
    
    private var languages: [LanguageDomainModel] = [LanguageDomainModel]()
    
    init(getAllToolLanguagesUseCase: GetAllToolLanguagesUseCase, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, toolFilterSelectionPublisher: CurrentValueSubject<ToolFilterSelection, Never>) {
        
        self.getAllToolLanguagesUseCase = getAllToolLanguagesUseCase
        
        super.init(localizationServices: localizationServices, getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase, toolFilterSelectionPublisher: toolFilterSelectionPublisher)
        
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (primaryLanguage: LanguageDomainModel?) in
                
                let primaryLocaleId: String? = primaryLanguage?.localeIdentifier

                self?.navTitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: primaryLocaleId, key: ToolStringKeys.ToolFilter.languageFilterNavTitle.rawValue)
            }
            .store(in: &cancellables)
        
        getAllToolLanguagesUseCase.getAllToolLanguagesPublisher(filteredByCategory: selectedCategory)
            .sink { [weak self] languages in
                
                self?.languages = languages
                self?.createRowViewModels(from: languages)
            }
            .store(in: &cancellables)
        
        searchTextPublisher
            .sink { [weak self] searchText in
                guard let self = self else { return }
                
                let filteredLanguages = self.languages.filter { searchText.isEmpty ? true : $0.translatedName.contains(searchText) }
                self.createRowViewModels(from: filteredLanguages)
            }
            .store(in: &cancellables)
        
        if let currentLanguageSelected = selectedLanguage {
            filterValueSelected = .language(languageModel: currentLanguageSelected)
        }
    }
}

// MARK: - Private

extension ToolFilterLanguageSelectionViewModel {
    
    private func createRowViewModels(from languages: [LanguageDomainModel]) {
        
        rowViewModels = languages.map { language in
            
            return ToolFilterSelectionRowViewModel(
                title: language.translatedName,
                subtitle: nil,
                toolsAvailableText: "some",
                filterValue: .language(languageModel: language)
            )
        }
    }
}
