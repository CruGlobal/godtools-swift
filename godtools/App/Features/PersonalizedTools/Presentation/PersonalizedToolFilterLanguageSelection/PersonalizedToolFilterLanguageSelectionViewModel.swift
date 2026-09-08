//
//  PersonalizedToolFilterLanguageSelectionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine
import Flow

@MainActor
final class PersonalizedToolFilterLanguageSelectionViewModel: ObservableObject {
        
    private let stepEmitter: FlowStepEmitter
    private let getPersonalizedToolFilterLanguagesStringsUseCase: GetPersonalizedToolFilterLanguagesStringsUseCase
    private let getPersonalizedToolFilterLanguagesUseCase: GetPersonalizedToolFilterLanguagesUseCase
    private let getUserPersonalizedToolFilterLanguageUseCase: GetUserPersonalizedToolFilterLanguageUseCase
    private let setUserPersonalizedToolFilterLanguageUseCase: SetUserPersonalizedToolFilterLanguageUseCase
    private let getSearchBarStringsUseCase: GetSearchBarStringsUseCase
    private let searchPersonalizedToolFilterLanguagesUseCase: SearchPersonalizedToolFilterLanguagesUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage = AppLanguageDomainModel.english
    @Published private var allLanguages: [PersonalizedToolFilterLanguageDomainModel] = Array()
    
    @Published private(set) var searchBarStrings = SearchBarStringsDomainModel.emptyValue
    @Published private(set) var strings = PersonalizedToolFilterLanguagesStringsDomainModel.emptyValue
    @Published private(set) var languageSearchResults: [PersonalizedToolFilterLanguageDomainModel] = Array()
    @Published private(set) var selectedLanguage: PersonalizedToolFilterLanguageDomainModel?
    
    @Published var searchText: String = ""
    
    init(
        stepEmitter: FlowStepEmitter,
        getPersonalizedToolFilterLanguagesStringsUseCase: GetPersonalizedToolFilterLanguagesStringsUseCase,
        getPersonalizedToolFilterLanguagesUseCase: GetPersonalizedToolFilterLanguagesUseCase,
        getUserPersonalizedToolFilterLanguageUseCase: GetUserPersonalizedToolFilterLanguageUseCase,
        setUserPersonalizedToolFilterLanguageUseCase: SetUserPersonalizedToolFilterLanguageUseCase,
        getSearchBarStringsUseCase: GetSearchBarStringsUseCase,
        searchPersonalizedToolFilterLanguagesUseCase: SearchPersonalizedToolFilterLanguagesUseCase,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.getPersonalizedToolFilterLanguagesStringsUseCase = getPersonalizedToolFilterLanguagesStringsUseCase
        self.getPersonalizedToolFilterLanguagesUseCase = getPersonalizedToolFilterLanguagesUseCase
        self.getUserPersonalizedToolFilterLanguageUseCase = getUserPersonalizedToolFilterLanguageUseCase
        self.setUserPersonalizedToolFilterLanguageUseCase = setUserPersonalizedToolFilterLanguageUseCase
        self.getSearchBarStringsUseCase = getSearchBarStringsUseCase
        self.searchPersonalizedToolFilterLanguagesUseCase = searchPersonalizedToolFilterLanguagesUseCase
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
                
                getPersonalizedToolFilterLanguagesUseCase
                    .execute(
                        appLanguage: appLanguage
                    )
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] languages in
                
                self?.allLanguages = languages
            })
            .store(in: &cancellables)
        
        getUserPersonalizedToolFilterLanguageUseCase
            .execute(appLanguage: appLanguage)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (languageFilter: PersonalizedToolFilterLanguageDomainModel?) in
                
                self?.selectedLanguage = languageFilter
            })
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $searchText,
            $allLanguages
        )
        .map { (searchText: String, languages: [PersonalizedToolFilterLanguageDomainModel]) in
            
            searchPersonalizedToolFilterLanguagesUseCase
                .execute(searchText: searchText, languages: languages)
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

        strings = getPersonalizedToolFilterLanguagesStringsUseCase
            .execute(appLanguage: appLanguage)
    }
}

// MARK: - Inputs

extension PersonalizedToolFilterLanguageSelectionViewModel {
    
    @objc func backTapped() {
        
        stepEmitter.emit(step: AppFlowStep.backTappedFromPersonalizedToolLanguageFilter)
    }
    
    func languageTapped(language: PersonalizedToolFilterLanguageDomainModel) {
        
        self.selectedLanguage = language
        
        let setUserPersonalizedToolFilterLanguageUseCase: SetUserPersonalizedToolFilterLanguageUseCase = self.setUserPersonalizedToolFilterLanguageUseCase
        
        Task.detached {
            
            try await setUserPersonalizedToolFilterLanguageUseCase
                .execute(language: language)
        }
        
        stepEmitter.emit(step: AppFlowStep.languageTappedFromPersonalizedToolLanguageFilter)
    }
}
