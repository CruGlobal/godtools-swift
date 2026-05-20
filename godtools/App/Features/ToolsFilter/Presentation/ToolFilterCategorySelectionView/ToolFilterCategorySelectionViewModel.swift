//
//  ToolFilterCategorySelectionViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
class ToolFilterCategorySelectionViewModel: ObservableObject {
        
    private let getToolFilterCategoriesStringsUseCase: GetToolFilterCategoriesStringsUseCase
    private let getToolFilterCategoriesUseCase: GetToolFilterCategoriesUseCase
    private let searchToolFilterCategoriesUseCase: SearchToolFilterCategoriesUseCase
    private let getUserToolFilterCategoryUseCase: GetUserToolFilterCategoryUseCase
    private let getUserToolFilterLanguageUseCase: GetUserToolFilterLanguageUseCase
    private let selectedToolFilterCategoryUseCase: SelectedToolFilterCategoryUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getSearchBarStringsUseCase: GetSearchBarStringsUseCase
        
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage = AppLanguageDomainModel.english
    @Published private var allCategories: [ToolFilterCategoryDomainModel] = Array()
    
    @Published private(set) var searchBarStrings = SearchBarStringsDomainModel.emptyValue
    @Published private(set) var strings = ToolFilterCategoriesStringsDomainModel.emptyValue
    @Published private(set) var selectedLanguage = ToolFilterLanguageDomainModel.emptyValue
    @Published private(set) var selectedCategory = ToolFilterCategoryDomainModel.emptyValue
    @Published private(set) var categorySearchResults: [ToolFilterCategoryDomainModel] = Array()
    
    @Published var searchText: String = ""
    
    init(getToolFilterCategoriesStringsUseCase: GetToolFilterCategoriesStringsUseCase, getToolFilterCategoriesUseCase: GetToolFilterCategoriesUseCase, searchToolFilterCategoriesUseCase: SearchToolFilterCategoriesUseCase, getUserToolFilterCategoryUseCase: GetUserToolFilterCategoryUseCase, getUserToolFilterLanguageUseCase: GetUserToolFilterLanguageUseCase, selectedToolFilterCategoryUseCase: SelectedToolFilterCategoryUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getSearchBarStringsUseCase: GetSearchBarStringsUseCase, flowDelegate: FlowDelegate) {
        
        self.getToolFilterCategoriesStringsUseCase = getToolFilterCategoriesStringsUseCase
        self.getToolFilterCategoriesUseCase = getToolFilterCategoriesUseCase
        self.searchToolFilterCategoriesUseCase = searchToolFilterCategoriesUseCase
        self.getUserToolFilterCategoryUseCase = getUserToolFilterCategoryUseCase
        self.getUserToolFilterLanguageUseCase = getUserToolFilterLanguageUseCase
        self.selectedToolFilterCategoryUseCase = selectedToolFilterCategoryUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getSearchBarStringsUseCase = getSearchBarStringsUseCase
        self.flowDelegate = flowDelegate
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (appLanguage: AppLanguageDomainModel) in
                self?.appLanguage = appLanguage
                self?.didSetApplanguage(appLanguage: appLanguage)
            }
            .store(in: &cancellables)
        
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
        
        Publishers.CombineLatest(
            $appLanguage.dropFirst(),
            $selectedLanguage
        )
        .map { (appLanguage: AppLanguageDomainModel, selectedLanguage: ToolFilterLanguageDomainModel) in
            
            getToolFilterCategoriesUseCase
                .execute(
                    appLanguage: appLanguage,
                    filteredByLanguage: selectedLanguage
                )
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
    
    private func didSetApplanguage(appLanguage: AppLanguageDomainModel) {
        
        searchBarStrings = getSearchBarStringsUseCase
            .execute(appLanguage: appLanguage)
        
        strings = getToolFilterCategoriesStringsUseCase
            .execute(appLanguage: appLanguage)
    }
}

// MARK: - Inputs

extension ToolFilterCategorySelectionViewModel {
    
    func categoryTapped(category: ToolFilterCategoryDomainModel) {
        
        selectedCategory = category
        
        Task {
            try await selectedToolFilterCategoryUseCase
                .execute(category: category)
        }
        
        flowDelegate?.navigate(step: .categoryTappedFromToolCategoryFilter)
    }
    
    @objc func backButtonTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromToolCategoryFilter)
    }
}
