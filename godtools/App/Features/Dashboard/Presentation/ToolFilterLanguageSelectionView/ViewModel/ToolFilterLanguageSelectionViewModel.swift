//
//  ToolFilterLanguageSelectionViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ToolFilterLanguageSelectionViewModel: ObservableObject {
    
    private let getToolFilterLanguagesUseCase: GetToolFilterLanguagesUseCase
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    private let languageFilterSelectionPublisher: CurrentValueSubject<LanguageFilterDomainModel, Never>
    private let searchTextPublisher: CurrentValueSubject<String, Never> = CurrentValueSubject("")
    private let selectedCategory: CategoryFilterDomainModel
    
    private var allLanguages: [LanguageFilterDomainModel] = [LanguageFilterDomainModel]()
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published var selectedLanguage: LanguageFilterDomainModel
    @Published var navTitle: String = ""
    @Published var languageSearchResults: [LanguageFilterDomainModel] = [LanguageFilterDomainModel]()
    
    init(getToolFilterLanguagesUseCase: GetToolFilterLanguagesUseCase, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, languageFilterSelectionPublisher: CurrentValueSubject<LanguageFilterDomainModel, Never>, selectedCategory: CategoryFilterDomainModel) {
        
        self.getToolFilterLanguagesUseCase = getToolFilterLanguagesUseCase
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.languageFilterSelectionPublisher = languageFilterSelectionPublisher
        self.selectedCategory = selectedCategory
        self.selectedLanguage = languageFilterSelectionPublisher.value
        
        getInterfaceStringInAppLanguageUseCase
            .getStringPublisher(id: ToolStringKeys.ToolFilter.languageFilterNavTitle.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: &$navTitle)
        
        getToolFilterLanguagesUseCase.getToolFilterLanguagesPublisher(filteredByCategory: selectedCategory)
            .sink { [weak self] languages in
                
                self?.allLanguages = languages
                self?.getSearchResults()
            }
            .store(in: &cancellables)
        
        searchTextPublisher
            .sink { [weak self] searchText in
                
                self?.getSearchResults()
            }
            .store(in: &cancellables)
        
        $selectedLanguage
            .sink { [weak self] language in
                
                self?.languageFilterSelectionPublisher.send(language)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Inputs

extension ToolFilterLanguageSelectionViewModel {
    
    func getSearchBarViewModel() -> SearchBarViewModel {
        
        return SearchBarViewModel(
            searchTextPublisher: searchTextPublisher,
            getInterfaceStringInAppLanguageUseCase: getInterfaceStringInAppLanguageUseCase
        )
    }
    
    func rowTapped(with language: LanguageFilterDomainModel) {
        
        selectedLanguage = language
    }
}

// MARK: - Private

extension ToolFilterLanguageSelectionViewModel {
    
    private func getSearchResults() {
        
        let searchText = searchTextPublisher.value
        
        if searchText.isEmpty == false {
            
            languageSearchResults = self.allLanguages.filter { $0.searchableText.contains(searchText) }
        } else {
            
            languageSearchResults = self.allLanguages
        }
    }
}
