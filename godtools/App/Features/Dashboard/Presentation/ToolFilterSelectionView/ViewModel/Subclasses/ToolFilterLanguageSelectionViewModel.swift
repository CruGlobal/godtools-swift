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
    
    init(getToolFilterLanguagesUseCase: GetToolFilterLanguagesUseCase, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, toolFilterSelectionPublisher: CurrentValueSubject<ToolFilterSelection, Never>) {
        
        self.getToolFilterLanguagesUseCase = getToolFilterLanguagesUseCase
        
        super.init(getInterfaceStringInAppLanguageUseCase: getInterfaceStringInAppLanguageUseCase, toolFilterSelectionPublisher: toolFilterSelectionPublisher)
        
        getInterfaceStringInAppLanguageUseCase
            .getStringPublisher(id: ToolStringKeys.ToolFilter.languageFilterNavTitle.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: &$navTitle)
        
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
