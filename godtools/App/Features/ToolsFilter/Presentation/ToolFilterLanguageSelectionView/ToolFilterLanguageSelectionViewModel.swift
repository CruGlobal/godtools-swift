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
    
    private let viewToolFilterLanguagesUseCase: ViewToolFilterLanguagesUseCase
    private let searchToolFilterLanguagesUseCase: SearchToolFilterLanguagesUseCase
    private let storeUserFilterUseCase: StoreUserFiltersUseCase
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewSearchBarUseCase: ViewSearchBarUseCase
    private let selectedCategory: CategoryFilterDomainModel
    
    private var cancellables: Set<AnyCancellable> = Set()
    private weak var flowDelegate: FlowDelegate?
    
    let selectedLanguage: CombineObservableValue<LanguageFilterDomainModel>
            
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published private var allLanguages: [LanguageFilterDomainModel] = [LanguageFilterDomainModel]()
    @Published var languageSearchResults: [LanguageFilterDomainModel] = [LanguageFilterDomainModel]()
    @Published var searchText: String = ""
    @Published var navTitle: String = ""
    
    init(viewToolFilterLanguagesUseCase: ViewToolFilterLanguagesUseCase,  searchToolFilterLanguagesUseCase: SearchToolFilterLanguagesUseCase, storeUserFilterUseCase: StoreUserFiltersUseCase, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewSearchBarUseCase: ViewSearchBarUseCase, selectedLanguage: CombineObservableValue<LanguageFilterDomainModel>, selectedCategory: CategoryFilterDomainModel, flowDelegate: FlowDelegate) {
        
        self.viewToolFilterLanguagesUseCase = viewToolFilterLanguagesUseCase
        self.searchToolFilterLanguagesUseCase = searchToolFilterLanguagesUseCase
        self.storeUserFilterUseCase = storeUserFilterUseCase
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewSearchBarUseCase = viewSearchBarUseCase
        self.selectedLanguage = selectedLanguage
        self.selectedCategory = selectedCategory
        self.flowDelegate = flowDelegate
                
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
                            
        $appLanguage.eraseToAnyPublisher()
            .flatMap { appLanguage in
                
                return viewToolFilterLanguagesUseCase.viewPublisher(filteredByCategoryId: selectedCategory.id, translatedInAppLanguage: appLanguage)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] viewLanguageFiltersDomainModel in
                
                self?.allLanguages = viewLanguageFiltersDomainModel.languageFilters
            }
            .store(in: &cancellables)

        getInterfaceStringInAppLanguageUseCase
            .getStringPublisher(id: ToolStringKeys.ToolFilter.languageFilterNavTitle.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: &$navTitle)
        
        Publishers.CombineLatest(
            $searchText.eraseToAnyPublisher(),
            $allLanguages.eraseToAnyPublisher()
        )
        .flatMap { searchText, allLanguages in
            
            return searchToolFilterLanguagesUseCase.getSearchResultsPublisher(for: searchText, in: allLanguages)
        }
        .receive(on: DispatchQueue.main)
        .assign(to: &$languageSearchResults)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
             
        selectedLanguage.value = language
        
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
