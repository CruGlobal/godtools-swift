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
    private let searchToolFilterLanguagesUseCase: SearchToolFilterLanguagesUseCase
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    private let languageFilterSelectionPublisher: CurrentValueSubject<LanguageFilterDomainModel, Never>
    private let searchTextPublisher: CurrentValueSubject<String, Never> = CurrentValueSubject("")
    private let selectedCategory: CategoryFilterDomainModel
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var allLanguages: [LanguageFilterDomainModel] = [LanguageFilterDomainModel]()
    @Published var selectedLanguage: LanguageFilterDomainModel
    @Published var navTitle: String = ""
    @Published var languageSearchResults: [LanguageFilterDomainModel] = [LanguageFilterDomainModel]()
    
    init(getToolFilterLanguagesUseCase: GetToolFilterLanguagesUseCase, searchToolFilterLanguagesUseCase: SearchToolFilterLanguagesUseCase, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, languageFilterSelectionPublisher: CurrentValueSubject<LanguageFilterDomainModel, Never>, selectedCategory: CategoryFilterDomainModel, flowDelegate: FlowDelegate?) {
        
        self.getToolFilterLanguagesUseCase = getToolFilterLanguagesUseCase
        self.searchToolFilterLanguagesUseCase = searchToolFilterLanguagesUseCase
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.languageFilterSelectionPublisher = languageFilterSelectionPublisher
        self.selectedCategory = selectedCategory
        self.selectedLanguage = languageFilterSelectionPublisher.value
        self.flowDelegate = flowDelegate
        
        getInterfaceStringInAppLanguageUseCase
            .getStringPublisher(id: ToolStringKeys.ToolFilter.languageFilterNavTitle.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: &$navTitle)
        
        getToolFilterLanguagesUseCase.getToolFilterLanguagesPublisher(filteredByCategory: selectedCategory)
            .receive(on: DispatchQueue.main)
            .assign(to: &$allLanguages)
        
        searchToolFilterLanguagesUseCase
            .getSearchResultsPublisher(for: searchTextPublisher.eraseToAnyPublisher(), in: $allLanguages.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .assign(to: &$languageSearchResults)
        
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
    
    @objc func backButtonTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromToolLanguageFilter)
    }
}
