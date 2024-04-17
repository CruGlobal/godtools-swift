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
    @Published private var allLanguages: [LanguageFilterDomainModel] = [LanguageFilterDomainModel]()
    
    @Published var languageSearchResults: [LanguageFilterDomainModel] = [LanguageFilterDomainModel]()
    @Published var selectedCategory: CategoryFilterDomainModel = .anyCategory(text: "Any category", toolsAvailableText: "")
    @Published var selectedLanguage: LanguageFilterDomainModel = .anyLanguage(text: "Any language", toolsAvailableText: "")
    @Published var searchText: String = ""
    @Published var navTitle: String = ""
    
    init(viewToolFilterLanguagesUseCase: ViewToolFilterLanguagesUseCase,  searchToolFilterLanguagesUseCase: SearchToolFilterLanguagesUseCase, getUserToolFiltersUseCase: GetUserToolFiltersUseCase, storeUserToolFilterUseCase: StoreUserToolFiltersUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewSearchBarUseCase: ViewSearchBarUseCase, flowDelegate: FlowDelegate) {
        
        self.viewToolFilterLanguagesUseCase = viewToolFilterLanguagesUseCase
        self.searchToolFilterLanguagesUseCase = searchToolFilterLanguagesUseCase
        self.getUserToolFiltersUseCase = getUserToolFiltersUseCase
        self.storeUserToolFilterUseCase = storeUserToolFilterUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewSearchBarUseCase = viewSearchBarUseCase
        self.flowDelegate = flowDelegate
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap { appLanguage in
                
                return getUserToolFiltersUseCase.getUserToolFiltersPublisher(translatedInAppLanguage: appLanguage)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userFilters in
            
                self?.selectedLanguage = userFilters.languageFilter
                self?.selectedCategory = userFilters.categoryFilter
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $appLanguage.eraseToAnyPublisher(),
            $selectedCategory.eraseToAnyPublisher()
        )
        .flatMap { appLanguage, selectedCategory in
            
            return viewToolFilterLanguagesUseCase.viewPublisher(filteredByCategoryId: selectedCategory.id, translatedInAppLanguage: appLanguage)
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] viewLanguageFiltersDomainModel in
            guard let self = self else { return }
            
            let interfaceStrings = viewLanguageFiltersDomainModel.interfaceStrings
            
            self.navTitle = interfaceStrings.navTitle
            self.allLanguages = viewLanguageFiltersDomainModel.languageFilters
            
        }
        .store(in: &cancellables)
        
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
        
        return searchBarViewModel
    }
        
    func rowTapped(with language: LanguageFilterDomainModel) {
        
        selectedLanguage = language
        
        storeUserToolFilterUseCase.storeLanguageFilterPublisher(with: language.id)
            .sink { _ in
                
            }
            .store(in: &ToolFilterLanguageSelectionViewModel.staticCancellables)
        
        flowDelegate?.navigate(step: .languageTappedFromToolLanguageFilter)
    }
    
    @objc func backButtonTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromToolLanguageFilter)
    }
}
