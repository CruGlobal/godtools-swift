//
//  ToolFilterLanguageSelectionViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import Flow

@MainActor
class ToolFilterLanguageSelectionViewModel: ObservableObject {
        
    private let stepEmitter: FlowStepEmitter
    private let getToolFilterLanguagesStringsUseCase: GetToolFilterLanguagesStringsUseCase
    private let getToolFilterLanguagesUseCase: GetToolFilterLanguagesUseCase
    private let searchToolFilterLanguagesUseCase: SearchToolFilterLanguagesUseCase
    private let getUserToolFilterCategoryUseCase: GetUserToolFilterCategoryUseCase
    private let getUserToolFilterLanguageUseCase: GetUserToolFilterLanguageUseCase
    private let selectedToolFilterLanguageUseCase: SelectedToolFilterLanguageUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getSearchBarStringsUseCase: GetSearchBarStringsUseCase
        
    private var cancellables: Set<AnyCancellable> = Set()
            
    @Published private var appLanguage = AppLanguageDomainModel.english
    @Published private var allLanguages: [ToolFilterLanguageDomainModel] = [ToolFilterLanguageDomainModel]()
    
    @Published private(set) var searchBarStrings = SearchBarStringsDomainModel.emptyValue
    @Published private(set) var strings = ToolFilterLanguagesStringsDomainModel.emptyValue
    @Published private(set) var selectedCategory = ToolFilterCategoryDomainModel.emptyValue
    @Published private(set) var selectedLanguage = ToolFilterLanguageDomainModel.emptyValue
    @Published private(set) var languageSearchResults: [ToolFilterLanguageDomainModel] = Array()
    
    @Published var searchText: String = ""
    
    init(
        stepEmitter: FlowStepEmitter,
        getToolFilterLanguagesStringsUseCase: GetToolFilterLanguagesStringsUseCase,
        getToolFilterLanguagesUseCase: GetToolFilterLanguagesUseCase,
        searchToolFilterLanguagesUseCase: SearchToolFilterLanguagesUseCase,
        getUserToolFilterCategoryUseCase: GetUserToolFilterCategoryUseCase,
        getUserToolFilterLanguageUseCase: GetUserToolFilterLanguageUseCase,
        selectedToolFilterLanguageUseCase: SelectedToolFilterLanguageUseCase,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getSearchBarStringsUseCase: GetSearchBarStringsUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.getToolFilterLanguagesStringsUseCase = getToolFilterLanguagesStringsUseCase
        self.getToolFilterLanguagesUseCase = getToolFilterLanguagesUseCase
        self.searchToolFilterLanguagesUseCase = searchToolFilterLanguagesUseCase
        self.getUserToolFilterCategoryUseCase = getUserToolFilterCategoryUseCase
        self.getUserToolFilterLanguageUseCase = getUserToolFilterLanguageUseCase
        self.selectedToolFilterLanguageUseCase = selectedToolFilterLanguageUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getSearchBarStringsUseCase = getSearchBarStringsUseCase
        
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
        .map { (searchText: String, allLanguages: [ToolFilterLanguageDomainModel]) in
            searchToolFilterLanguagesUseCase
                .execute(searchText: searchText, toolFilterLanguages: allLanguages)
        }
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
        
        let selectedToolFilterLanguageUseCase: SelectedToolFilterLanguageUseCase = self.selectedToolFilterLanguageUseCase
        
        Task.detached {
            
            try await selectedToolFilterLanguageUseCase
                .execute(language: language)
        }
        
        stepEmitter.emit(step: AppFlowStep.languageTappedFromToolLanguageFilter)
    }
    
    @objc func backButtonTapped() {
        
        stepEmitter.emit(step: AppFlowStep.backTappedFromToolLanguageFilter)
    }
}
