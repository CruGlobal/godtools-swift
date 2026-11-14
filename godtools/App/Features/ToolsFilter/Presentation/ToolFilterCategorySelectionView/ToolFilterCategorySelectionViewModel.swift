//
//  ToolFilterCategorySelectionViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import Flow

@MainActor
final class ToolFilterCategorySelectionViewModel: ObservableObject {

    enum Mode: Sendable {
        case allTools
        case personalized
    }
        
    private let stepEmitter: FlowStepEmitter
    private let getToolFilterCategoriesStringsUseCase: GetToolFilterCategoriesStringsUseCase
    private let getToolFilterCategoriesUseCase: GetToolFilterCategoriesUseCase
    private let searchToolFilterCategoriesUseCase: SearchToolFilterCategoriesUseCase
    private let getUserToolFilterCategoryUseCase: GetUserToolFilterCategoryUseCase
    private let getUserToolFilterLanguageUseCase: GetUserToolFilterLanguageUseCase
    private let getUserPersonalizedToolFilterLanguageUseCase: GetUserPersonalizedToolFilterLanguageUseCase
    private let getPersonalizedToolFilterCategoriesUseCase: GetPersonalizedToolFilterCategoriesUseCase
    private let getLocalizationSettingsUseCase: GetLocalizationSettingsUseCase
    private let selectedToolFilterCategoryUseCase: SelectedToolFilterCategoryUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getSearchBarStringsUseCase: GetSearchBarStringsUseCase
        
    private var cancellables: Set<AnyCancellable> = Set()
        
    @Published private var appLanguage = AppLanguageDomainModel.english
    @Published private var allCategories: [ToolFilterCategoryDomainModel] = Array()
    @Published private var localizationSettings: UserLocalizationSettingsDomainModel?
    
    @Published private(set) var searchBarStrings = SearchBarStringsDomainModel.emptyValue
    @Published private(set) var strings = ToolFilterCategoriesStringsDomainModel.emptyValue
    @Published private(set) var selectedLanguageId: String?
    @Published private(set) var selectedCategory = ToolFilterCategoryDomainModel.emptyValue
    @Published private(set) var categorySearchResults: [ToolFilterCategoryDomainModel] = Array()
    
    @Published var searchText: String = ""
    
    init(
        stepEmitter: FlowStepEmitter,
        mode: Mode,
        getToolFilterCategoriesStringsUseCase: GetToolFilterCategoriesStringsUseCase,
        getToolFilterCategoriesUseCase: GetToolFilterCategoriesUseCase,
        searchToolFilterCategoriesUseCase: SearchToolFilterCategoriesUseCase,
        getUserToolFilterCategoryUseCase: GetUserToolFilterCategoryUseCase,
        getUserToolFilterLanguageUseCase: GetUserToolFilterLanguageUseCase,
        getUserPersonalizedToolFilterLanguageUseCase: GetUserPersonalizedToolFilterLanguageUseCase,
        getPersonalizedToolFilterCategoriesUseCase: GetPersonalizedToolFilterCategoriesUseCase,
        getLocalizationSettingsUseCase: GetLocalizationSettingsUseCase,
        selectedToolFilterCategoryUseCase: SelectedToolFilterCategoryUseCase,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getSearchBarStringsUseCase: GetSearchBarStringsUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.getToolFilterCategoriesStringsUseCase = getToolFilterCategoriesStringsUseCase
        self.getToolFilterCategoriesUseCase = getToolFilterCategoriesUseCase
        self.searchToolFilterCategoriesUseCase = searchToolFilterCategoriesUseCase
        self.getUserToolFilterCategoryUseCase = getUserToolFilterCategoryUseCase
        self.getUserToolFilterLanguageUseCase = getUserToolFilterLanguageUseCase
        self.getUserPersonalizedToolFilterLanguageUseCase = getUserPersonalizedToolFilterLanguageUseCase
        self.getPersonalizedToolFilterCategoriesUseCase = getPersonalizedToolFilterCategoriesUseCase
        self.getLocalizationSettingsUseCase = getLocalizationSettingsUseCase
        self.selectedToolFilterCategoryUseCase = selectedToolFilterCategoryUseCase
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
                
                getUserToolFilterCategoryUseCase.execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .assign(to: &$selectedCategory)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) -> AnyPublisher<String?, Never> in

                switch mode {

                case .allTools:
                    return getUserToolFilterLanguageUseCase
                        .execute(appLanguage: appLanguage)
                        .map { $0.languageId }
                        .eraseToAnyPublisher()

                case .personalized:
                    return getUserPersonalizedToolFilterLanguageUseCase
                        .execute(appLanguage: appLanguage)
                        .map { $0?.languageId }
                        .replaceError(with: nil)
                        .eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .assign(to: &$selectedLanguageId)

        getLocalizationSettingsUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$localizationSettings)

        Publishers.CombineLatest3(
            $appLanguage.dropFirst(),
            $selectedLanguageId,
            $localizationSettings
        )
        .map { (
            appLanguage: AppLanguageDomainModel,
            selectedLanguageId: String?,
            localizationSettings: UserLocalizationSettingsDomainModel?
        ) -> AnyPublisher<[ToolFilterCategoryDomainModel], Error> in

            switch mode {

            case .allTools:
                return getToolFilterCategoriesUseCase
                    .execute(
                        appLanguage: appLanguage,
                        filteredByLanguageId: selectedLanguageId
                    )

            case .personalized:
                return getPersonalizedToolFilterCategoriesUseCase
                    .execute(
                        appLanguage: appLanguage,
                        country: localizationSettings?.selectedCountry,
                        filterByLanguageId: selectedLanguageId
                    )
            }
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
        .map { (searchText: String, allCategories: [ToolFilterCategoryDomainModel]) in
            searchToolFilterCategoriesUseCase
                .execute(searchText: searchText, toolFilterCategories: allCategories)
        }
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
        
        let selectedToolFilterCategoryUseCase: SelectedToolFilterCategoryUseCase = self.selectedToolFilterCategoryUseCase
        
        Task.detached {
            
            try await selectedToolFilterCategoryUseCase
                .execute(category: category)
        }
        
        stepEmitter.emit(step: AppFlowStep.categoryTappedFromToolCategoryFilter)
    }
    
    @objc func backButtonTapped() {
        
        stepEmitter.emit(step: AppFlowStep.backTappedFromToolCategoryFilter)
    }
}
