//
//  ToolFilterCategorySelectionViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class ToolFilterCategorySelectionViewModel: ObservableObject {
    
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    private let getToolFilterCategoriesStringsUseCase: GetToolFilterCategoriesStringsUseCase
    private let getToolFilterCategoriesUseCase: GetToolFilterCategoriesUseCase
    private let searchToolFilterCategoriesUseCase: SearchToolFilterCategoriesUseCase
    private let getUserToolFilterCategoryUseCase: GetUserToolFilterCategoryUseCase
    private let getUserToolFilterLanguageUseCase: GetUserToolFilterLanguageUseCase
    private let selectedToolFilterCategoryUseCase: SelectedToolFilterCategoryUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewSearchBarUseCase: ViewSearchBarUseCase
    
    private lazy var searchBarViewModel = SearchBarViewModel(getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, viewSearchBarUseCase: viewSearchBarUseCase)
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var allCategories: [ToolFilterCategoryDomainModel] = [ToolFilterCategoryDomainModel]()
    
    @Published private(set) var strings = ToolFilterCategoriesStringsDomainModel.emptyValue
    @Published private(set) var selectedLanguage: ToolFilterLanguageDomainModel = ToolFilterAnyLanguageDomainModel(text: "", toolsAvailableText: "", numberOfToolsAvailable: 0)
    @Published private(set) var selectedCategory: ToolFilterCategoryDomainModel = ToolFilterAnyCategoryDomainModel(text: "", toolsAvailableText: "")
    
    @Published var searchText: String = ""
    @Published var categorySearchResults: [ToolFilterCategoryDomainModel] = [ToolFilterCategoryDomainModel]()
    
    init(getToolFilterCategoriesStringsUseCase: GetToolFilterCategoriesStringsUseCase, getToolFilterCategoriesUseCase: GetToolFilterCategoriesUseCase, searchToolFilterCategoriesUseCase: SearchToolFilterCategoriesUseCase, getUserToolFilterCategoryUseCase: GetUserToolFilterCategoryUseCase, getUserToolFilterLanguageUseCase: GetUserToolFilterLanguageUseCase, selectedToolFilterCategoryUseCase: SelectedToolFilterCategoryUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewSearchBarUseCase: ViewSearchBarUseCase, flowDelegate: FlowDelegate) {
        
        self.getToolFilterCategoriesStringsUseCase = getToolFilterCategoriesStringsUseCase
        self.getToolFilterCategoriesUseCase = getToolFilterCategoriesUseCase
        self.searchToolFilterCategoriesUseCase = searchToolFilterCategoriesUseCase
        self.getUserToolFilterCategoryUseCase = getUserToolFilterCategoryUseCase
        self.getUserToolFilterLanguageUseCase = getUserToolFilterLanguageUseCase
        self.selectedToolFilterCategoryUseCase = selectedToolFilterCategoryUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewSearchBarUseCase = viewSearchBarUseCase
        self.flowDelegate = flowDelegate
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                Publishers.CombineLatest(
                    getUserToolFilterCategoryUseCase.execute(appLanguage: appLanguage),
                    getUserToolFilterLanguageUseCase.execute(appLanguage: appLanguage)
                )
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (categoryFilter: ToolFilterCategoryDomainModel, languageFilter: ToolFilterLanguageDomainModel) in
            
                self?.selectedCategory = categoryFilter
                self?.selectedLanguage = languageFilter
            }
            .store(in: &cancellables)
        
        $appLanguage.dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                getToolFilterCategoriesStringsUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: ToolFilterCategoriesStringsDomainModel) in
                
                self?.strings = strings
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $appLanguage.dropFirst(),
            $selectedLanguage
        )
        .map { (appLanguage: AppLanguageDomainModel, selectedLanguage: ToolFilterLanguageDomainModel) in
            
            getToolFilterCategoriesUseCase
                .execute(appLanguage: appLanguage, filteredByLanguageId: selectedLanguage.id)
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in
            
        }, receiveValue: { [weak self] (categoryFilters: [ToolFilterCategoryDomainModel]) in
            
            self?.allCategories = categoryFilters
        })
        .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $searchText,
            $allCategories
        )
        .map { searchText, allCategories in
            
            searchToolFilterCategoriesUseCase
                .execute(for: searchText, in: allCategories)
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
    
    func rowTapped(with category: ToolFilterCategoryDomainModel) {
        
        selectedCategory = category
        
        selectedToolFilterCategoryUseCase
            .execute(id: category.id)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            }
            .store(in: &Self.backgroundCancellables)
        
        flowDelegate?.navigate(step: .categoryTappedFromToolCategoryFilter)
    }
    
    @objc func backButtonTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromToolCategoryFilter)
    }
}
