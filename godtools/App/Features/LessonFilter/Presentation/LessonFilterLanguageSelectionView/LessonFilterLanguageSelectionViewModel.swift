//
//  LessonFilterLanguageSelectionViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class LessonFilterLanguageSelectionViewModel: ObservableObject {
    
    private static var staticCancellables: Set<AnyCancellable> = Set()
    
    private let stepEmitter: FlowStepEmitter
    private let getLessonFilterLanguagesStringsUseCase: GetLessonFilterLanguagesStringsUseCase
    private let getLessonFilterLanguagesUseCase: GetLessonFilterLanguagesUseCase
    private let getUserLessonFiltersUseCase: GetUserLessonFiltersUseCase
    private let storeUserLessonFiltersUseCase: StoreUserLessonFiltersUseCase
    private let getSearchBarStringsUseCase: GetSearchBarStringsUseCase
    private let searchLessonFilterLanguagesUseCase: SearchLessonFilterLanguagesUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage = AppLanguageDomainModel.english
    @Published private var allLanguages: [LessonFilterLanguageDomainModel] = Array()
    
    @Published private(set) var searchBarStrings = SearchBarStringsDomainModel.emptyValue
    @Published private(set) var strings = LessonFilterLanguagesStringsDomainModel.emptyValue
    
    @Published var searchText: String = ""
    @Published var languageSearchResults: [LessonFilterLanguageDomainModel] = Array()
    @Published var selectedLanguage: LessonFilterLanguageDomainModel?
    
    init(stepEmitter: FlowStepEmitter, getLessonFilterLanguagesStringsUseCase: GetLessonFilterLanguagesStringsUseCase, getLessonFilterLanguagesUseCase: GetLessonFilterLanguagesUseCase, getUserLessonFiltersUseCase: GetUserLessonFiltersUseCase, storeUserLessonFiltersUseCase: StoreUserLessonFiltersUseCase, getSearchBarStringsUseCase: GetSearchBarStringsUseCase, searchLessonFilterLanguagesUseCase: SearchLessonFilterLanguagesUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase) {
        
        self.stepEmitter = stepEmitter
        self.getLessonFilterLanguagesStringsUseCase = getLessonFilterLanguagesStringsUseCase
        self.getLessonFilterLanguagesUseCase = getLessonFilterLanguagesUseCase
        self.getUserLessonFiltersUseCase = getUserLessonFiltersUseCase
        self.storeUserLessonFiltersUseCase = storeUserLessonFiltersUseCase
        self.getSearchBarStringsUseCase = getSearchBarStringsUseCase
        self.searchLessonFilterLanguagesUseCase = searchLessonFilterLanguagesUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        
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
                
                getLessonFilterLanguagesUseCase
                    .execute(
                        appLanguage: appLanguage
                    )
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (filterLanguages: [LessonFilterLanguageDomainModel]) in
                
                self?.allLanguages = filterLanguages
            })
            .store(in: &cancellables)
        
        $appLanguage
            .dropFirst()
            .map { appLanguage in
            
                getUserLessonFiltersUseCase
                    .execute(
                        appLanguage: appLanguage
                    )
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (userFilters: UserLessonFiltersDomainModel) in
                                
                guard self?.selectedLanguage == nil, let languageFilter = userFilters.languageFilter else {
                    return
                }
                
                self?.selectedLanguage = languageFilter
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $searchText,
            $allLanguages
        )
        .flatMap { (searchText: String, languages: [LessonFilterLanguageDomainModel]) in
            
            searchLessonFilterLanguagesUseCase
                .execute(
                    for: searchText,
                    in: languages
                )
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
        
        strings = getLessonFilterLanguagesStringsUseCase
            .execute(appLanguage: appLanguage)
    }
}

// MARK: - Inputs

extension LessonFilterLanguageSelectionViewModel {
    
    @objc func backTapped() {
        
        stepEmitter.emit(step: AppFlowStep.backTappedFromLessonLanguageFilter)
    }
    
    func languageTapped(_ language: LessonFilterLanguageDomainModel) {
        
        selectedLanguage = language
        
        storeUserLessonFiltersUseCase
            .execute(languageFilter: language)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            }
            .store(in: &LessonFilterLanguageSelectionViewModel.staticCancellables)
        
        stepEmitter.emit(step: AppFlowStep.languageTappedFromLessonLanguageFilter)
    }
}
