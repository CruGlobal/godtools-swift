//
//  ToolFilterCategorySelectionViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ToolFilterCategorySelectionViewModel: ObservableObject {
    
    private let viewToolFilterCategoriesUseCase: ViewToolFilterCategoriesUseCase
    private let searchToolFilterCategoriesUseCase: SearchToolFilterCategoriesUseCase
    private let getUserToolFiltersUseCase: GetUserToolFiltersUseCase
    private let storeUserToolFiltersUseCase: StoreUserToolFiltersUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewSearchBarUseCase: ViewSearchBarUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    private static var staticCancellables: Set<AnyCancellable> = Set()
    private weak var flowDelegate: FlowDelegate?
    private lazy var searchBarViewModel = SearchBarViewModel(getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, viewSearchBarUseCase: viewSearchBarUseCase)
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var allCategories: [ToolFilterCategoryDomainModelInterface] = [ToolFilterCategoryDomainModelInterface]()
    
    @Published var searchText: String = ""
    @Published var selectedLanguage: ToolFilterLanguageDomainModelInterface = ToolFilterAnyLanguageDomainModel(text: "", toolsAvailableText: "")
    @Published var selectedCategory: ToolFilterCategoryDomainModelInterface = ToolFilterAnyCategoryDomainModel(text: "", toolsAvailableText: "")
    @Published var navTitle: String = ""
    @Published var categorySearchResults: [ToolFilterCategoryDomainModelInterface] = [ToolFilterCategoryDomainModelInterface]()
    
    init(viewToolFilterCategoriesUseCase: ViewToolFilterCategoriesUseCase, searchToolFilterCategoriesUseCase: SearchToolFilterCategoriesUseCase, getUserToolFiltersUseCase: GetUserToolFiltersUseCase, storeUserToolFiltersUseCase: StoreUserToolFiltersUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewSearchBarUseCase: ViewSearchBarUseCase, flowDelegate: FlowDelegate) {
        
        self.viewToolFilterCategoriesUseCase = viewToolFilterCategoriesUseCase
        self.searchToolFilterCategoriesUseCase = searchToolFilterCategoriesUseCase
        self.getUserToolFiltersUseCase = getUserToolFiltersUseCase
        self.storeUserToolFiltersUseCase = storeUserToolFiltersUseCase
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
            $selectedLanguage
        )
        .map { appLanguage, selectedLanguage in
            
            viewToolFilterCategoriesUseCase
                .viewPublisher(filteredByLanguageId: selectedLanguage.id, translatedInAppLanguage: appLanguage)
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] viewCategoryFiltersDomainModel in
            guard let self = self else { return }
            
            let interfaceStrings = viewCategoryFiltersDomainModel.interfaceStrings
            
            self.navTitle = interfaceStrings.navTitle
            self.allCategories = viewCategoryFiltersDomainModel.categoryFilters
        }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $searchText,
            $allCategories
        )
        .map { searchText, allCategories in
            
            searchToolFilterCategoriesUseCase
                .getSearchResultsPublisher(for: searchText, in: allCategories)
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .assign(to: &$categorySearchResults)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}

// MARK: - Inputs

extension ToolFilterCategorySelectionViewModel {
    
    func getSearchBarViewModel() -> SearchBarViewModel {
        
        return searchBarViewModel
    }
    
    func rowTapped(with category: ToolFilterCategoryDomainModelInterface) {
        
        selectedCategory = category
        
        storeUserToolFiltersUseCase.storeCategoryFilterPublisher(with: category.id)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            }
            .store(in: &ToolFilterCategorySelectionViewModel.staticCancellables)
        
        flowDelegate?.navigate(step: .categoryTappedFromToolCategoryFilter)
    }
    
    @objc func backButtonTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromToolCategoryFilter)
    }
}
