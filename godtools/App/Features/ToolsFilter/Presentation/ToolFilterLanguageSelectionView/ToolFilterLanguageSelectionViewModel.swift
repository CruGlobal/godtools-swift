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
    private let storeUserFilterUseCase: StoreUserFiltersUseCase
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewSearchBarUseCase: ViewSearchBarUseCase
    private let languageFilterSelectionPublisher: CurrentValueSubject<LanguageFilterDomainModel, Never>
    private let selectedCategory: CategoryFilterDomainModel
    
    private var cancellables: Set<AnyCancellable> = Set()
    private weak var flowDelegate: FlowDelegate?
    
    let selectedLanguage: LanguageFilterDomainModel
    
    @Published private var allLanguages: [LanguageFilterDomainModel] = [LanguageFilterDomainModel]()
    @Published var languageSearchResults: [LanguageFilterDomainModel] = [LanguageFilterDomainModel]()
    @Published var searchText: String = ""
    @Published var navTitle: String = ""
    
    init(getToolFilterLanguagesUseCase: GetToolFilterLanguagesUseCase, searchToolFilterLanguagesUseCase: SearchToolFilterLanguagesUseCase, storeUserFilterUseCase: StoreUserFiltersUseCase, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewSearchBarUseCase: ViewSearchBarUseCase, languageFilterSelectionPublisher: CurrentValueSubject<LanguageFilterDomainModel, Never>, selectedCategory: CategoryFilterDomainModel, flowDelegate: FlowDelegate?) {
        
        self.getToolFilterLanguagesUseCase = getToolFilterLanguagesUseCase
        self.searchToolFilterLanguagesUseCase = searchToolFilterLanguagesUseCase
        self.storeUserFilterUseCase = storeUserFilterUseCase
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewSearchBarUseCase = viewSearchBarUseCase
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
            .getSearchResultsPublisher(
                for: $searchText.eraseToAnyPublisher(),
                in: $allLanguages.eraseToAnyPublisher()
            )
            .receive(on: DispatchQueue.main)
            .assign(to: &$languageSearchResults)
    }
}

// MARK: - Inputs

extension ToolFilterLanguageSelectionViewModel {
    
    func getSearchBarViewModel() -> SearchBarViewModel {
        
        return SearchBarViewModel(
            getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase,
            viewSearchBarUseCase: viewSearchBarUseCase
        )
    }
        
    func rowTapped(with language: LanguageFilterDomainModel) {
                
        languageFilterSelectionPublisher.send(language)
        
        storeUserFilterUseCase.storeLanguageFilterPublisher(with: language.id)
            .sink { _ in
                
            }
            .store(in: &cancellables)
        
        flowDelegate?.navigate(step: .languageTappedFromToolLanguageFilter)
    }
    
    @objc func backButtonTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromToolLanguageFilter)
    }
}
