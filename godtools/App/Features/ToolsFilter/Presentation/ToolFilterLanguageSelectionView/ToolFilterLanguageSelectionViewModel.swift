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
    private let getUserToolFiltersUseCase: GetUserToolFiltersUseCase
    private let storeUserToolFilterUseCase: StoreUserToolFiltersUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewSearchBarUseCase: ViewSearchBarUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    private static var staticCancellables: Set<AnyCancellable> = Set()
    private weak var flowDelegate: FlowDelegate?
    private lazy var searchBarViewModel = SearchBarViewModel(getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, viewSearchBarUseCase: viewSearchBarUseCase)
        
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var allLanguages: [ToolFilterLanguageDomainModel] = [ToolFilterLanguageDomainModel]()
    
    @Published var languageSearchResults: [ToolFilterLanguageDomainModel] = [ToolFilterLanguageDomainModel]()
    @Published var selectedCategory: ToolFilterCategoryDomainModel = ToolFilterAnyCategoryDomainModel(text: "Any category", toolsAvailableText: "")
    @Published var selectedLanguage: ToolFilterLanguageDomainModel = ToolFilterAnyLanguageDomainModel(text: "", toolsAvailableText: "")
    @Published var searchText: String = ""
    @Published var navTitle: String = ""
    
    init(viewToolFilterLanguagesUseCase: ViewToolFilterLanguagesUseCase, searchToolFilterLanguagesUseCase: SearchToolFilterLanguagesUseCase, getUserToolFiltersUseCase: GetUserToolFiltersUseCase, storeUserToolFilterUseCase: StoreUserToolFiltersUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewSearchBarUseCase: ViewSearchBarUseCase, flowDelegate: FlowDelegate) {
        
        self.viewToolFilterLanguagesUseCase = viewToolFilterLanguagesUseCase
        self.searchToolFilterLanguagesUseCase = searchToolFilterLanguagesUseCase
        self.getUserToolFiltersUseCase = getUserToolFiltersUseCase
        self.storeUserToolFilterUseCase = storeUserToolFilterUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewSearchBarUseCase = viewSearchBarUseCase
        self.flowDelegate = flowDelegate
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { appLanguage in
                
                getUserToolFiltersUseCase
                    .getUserToolFiltersPublisher(translatedInAppLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userFilters in
            
                self?.selectedLanguage = userFilters.languageFilter
                self?.selectedCategory = userFilters.categoryFilter
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $appLanguage.dropFirst(),
            $selectedCategory
        )
        .map { appLanguage, selectedCategory in
            
            viewToolFilterLanguagesUseCase
                .viewPublisher(filteredByCategoryId: selectedCategory.id, translatedInAppLanguage: appLanguage)
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] viewLanguageFiltersDomainModel in
            
            guard let self = self else {
                return
            }
            
            let interfaceStrings = viewLanguageFiltersDomainModel.interfaceStrings
            
            self.navTitle = interfaceStrings.navTitle
            self.allLanguages = viewLanguageFiltersDomainModel.languageFilters
            
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $searchText,
            $allLanguages
        )
        .map { searchText, allLanguages in
            
            searchToolFilterLanguagesUseCase
                .getSearchResultsPublisher(for: searchText, in: allLanguages)
        }
        .switchToLatest()
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
        
        return searchBarViewModel
    }
        
    func rowTapped(with language: ToolFilterLanguageDomainModel) {
        
        selectedLanguage = language
        
        storeUserToolFilterUseCase
            .storeLanguageFilterPublisher(with: language.id)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            }
            .store(in: &ToolFilterLanguageSelectionViewModel.staticCancellables)
        
        flowDelegate?.navigate(step: .languageTappedFromToolLanguageFilter)
    }
    
    @objc func backButtonTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromToolLanguageFilter)
    }
}
