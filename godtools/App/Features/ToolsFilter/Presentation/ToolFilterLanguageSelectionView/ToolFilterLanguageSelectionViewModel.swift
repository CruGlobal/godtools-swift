//
//  ToolFilterLanguageSelectionViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
class ToolFilterLanguageSelectionViewModel: ObservableObject {
        
    private let getToolFilterLanguagesStringsUseCase: GetToolFilterLanguagesStringsUseCase
    private let getToolFilterLanguagesUseCase: GetToolFilterLanguagesUseCase
    private let searchToolFilterLanguagesUseCase: SearchToolFilterLanguagesUseCase
    private let getUserToolFilterCategoryUseCase: GetUserToolFilterCategoryUseCase
    private let getUserToolFilterLanguageUseCase: GetUserToolFilterLanguageUseCase
    private let selectedToolFilterLanguageUseCase: SelectedToolFilterLanguageUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getSearchBarStringsUseCase: GetSearchBarStringsUseCase
        
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
        
    @Published private var appLanguage = AppLanguageDomainModel.english
    @Published private var allLanguages: [ToolFilterLanguageDomainModel] = [ToolFilterLanguageDomainModel]()
    
    @Published private(set) var searchBarStrings = SearchBarStringsDomainModel.emptyValue
    @Published private(set) var strings = ToolFilterLanguagesStringsDomainModel.emptyValue
    @Published private(set) var selectedCategory = ToolFilterCategoryDomainModel.emptyValue
    @Published private(set) var selectedLanguage = ToolFilterLanguageDomainModel.emptyValue
    @Published private(set) var languageSearchResults: [ToolFilterLanguageDomainModel] = Array()
    
    @Published var searchText: String = ""
    
    init(getToolFilterLanguagesStringsUseCase: GetToolFilterLanguagesStringsUseCase, getToolFilterLanguagesUseCase: GetToolFilterLanguagesUseCase, searchToolFilterLanguagesUseCase: SearchToolFilterLanguagesUseCase, getUserToolFilterCategoryUseCase: GetUserToolFilterCategoryUseCase, getUserToolFilterLanguageUseCase: GetUserToolFilterLanguageUseCase, selectedToolFilterLanguageUseCase: SelectedToolFilterLanguageUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getSearchBarStringsUseCase: GetSearchBarStringsUseCase, flowDelegate: FlowDelegate) {
        
        self.getToolFilterLanguagesStringsUseCase = getToolFilterLanguagesStringsUseCase
        self.getToolFilterLanguagesUseCase = getToolFilterLanguagesUseCase
        self.searchToolFilterLanguagesUseCase = searchToolFilterLanguagesUseCase
        self.getUserToolFilterCategoryUseCase = getUserToolFilterCategoryUseCase
        self.getUserToolFilterLanguageUseCase = getUserToolFilterLanguageUseCase
        self.selectedToolFilterLanguageUseCase = selectedToolFilterLanguageUseCase
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
            $selectedCategory
        )
        .map { (appLanguage: AppLanguageDomainModel, selectedCategory: ToolFilterCategoryDomainModel) in
            
            getToolFilterLanguagesUseCase
                .execute(appLanguage: appLanguage, filteredByCategory: selectedCategory)
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in
            
        }, receiveValue: { [weak self] (languageFilters: [ToolFilterLanguageDomainModel]) in
            
            self?.allLanguages = languageFilters
        })
        .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $searchText,
            $allLanguages
        )
        .map { searchText, allLanguages in
            
            searchToolFilterLanguagesUseCase
                .execute(for: searchText, in: allLanguages)
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .assign(to: &$languageSearchResults)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func didSetApplanguage(appLanguage: AppLanguageDomainModel) {
        
        searchBarStrings = getSearchBarStringsUseCase
            .execute(appLanguage: appLanguage)
        
        strings = getToolFilterLanguagesStringsUseCase
            .execute(appLanguage: appLanguage)
    }
}

// MARK: - Inputs

extension ToolFilterLanguageSelectionViewModel {
       
    func languageTapped(language: ToolFilterLanguageDomainModel) {
        
        selectedLanguage = language
        
        Task {
            
            try await selectedToolFilterLanguageUseCase
                .execute(language: language)
        }
        
        flowDelegate?.navigate(step: .languageTappedFromToolLanguageFilter)
    }
    
    @objc func backButtonTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromToolLanguageFilter)
    }
}
