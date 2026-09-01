//
//  PersonalizedLessonFilterLanguageSelectionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine
import Flow

@MainActor
final class PersonalizedLessonFilterLanguageSelectionViewModel: ObservableObject {
        
    private let stepEmitter: FlowStepEmitter
    private let getPersonalizedLessonFilterLanguagesStringsUseCase: GetPersonalizedLessonFilterLanguagesStringsUseCase
    private let getPersonalizedLessonFilterLanguagesUseCase: GetPersonalizedLessonFilterLanguagesUseCase
    private let getUserPersonalizedLessonFilterLanguageUseCase: GetUserPersonalizedLessonFilterLanguageUseCase
    private let setUserPersonalizedLessonFilterLanguageUseCase: SetUserPersonalizedLessonFilterLanguageUseCase
    private let getSearchBarStringsUseCase: GetSearchBarStringsUseCase
    private let searchPersonalizedLessonFilterLanguagesUseCase: SearchPersonalizedLessonFilterLanguagesUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage = AppLanguageDomainModel.english
    @Published private var allLanguages: [ToolLanguageFilterItemDomainModel] = Array()
    
    @Published private(set) var searchBarStrings = SearchBarStringsDomainModel.emptyValue
    @Published private(set) var strings = PersonalizedLessonFilterLanguagesStringsDomainModel.emptyValue
    @Published private(set) var languageSearchResults: [ToolLanguageFilterItemDomainModel] = Array()
    @Published private(set) var selectedLanguageId: String?
    
    @Published var searchText: String = ""
    
    init(
        stepEmitter: FlowStepEmitter,
        getPersonalizedLessonFilterLanguagesStringsUseCase: GetPersonalizedLessonFilterLanguagesStringsUseCase,
        getPersonalizedLessonFilterLanguagesUseCase: GetPersonalizedLessonFilterLanguagesUseCase,
        getUserPersonalizedLessonFilterLanguageUseCase: GetUserPersonalizedLessonFilterLanguageUseCase,
        setUserPersonalizedLessonFilterLanguageUseCase: SetUserPersonalizedLessonFilterLanguageUseCase,
        getSearchBarStringsUseCase: GetSearchBarStringsUseCase,
        searchPersonalizedLessonFilterLanguagesUseCase: SearchPersonalizedLessonFilterLanguagesUseCase,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.getPersonalizedLessonFilterLanguagesStringsUseCase = getPersonalizedLessonFilterLanguagesStringsUseCase
        self.getPersonalizedLessonFilterLanguagesUseCase = getPersonalizedLessonFilterLanguagesUseCase
        self.getUserPersonalizedLessonFilterLanguageUseCase = getUserPersonalizedLessonFilterLanguageUseCase
        self.setUserPersonalizedLessonFilterLanguageUseCase = setUserPersonalizedLessonFilterLanguageUseCase
        self.getSearchBarStringsUseCase = getSearchBarStringsUseCase
        self.searchPersonalizedLessonFilterLanguagesUseCase = searchPersonalizedLessonFilterLanguagesUseCase
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
                
                getPersonalizedLessonFilterLanguagesUseCase
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
        
        $appLanguage
            .dropFirst()
            .map { appLanguage in
            
                getUserPersonalizedLessonFilterLanguageUseCase
                    .execute(
                        appLanguage: appLanguage
                    )
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] languageId in
                
                self?.selectedLanguageId = languageId
            })
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $searchText,
            $allLanguages
        )
        .map { (searchText: String, languages: [ToolLanguageFilterItemDomainModel]) in
            
            searchPersonalizedLessonFilterLanguagesUseCase
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

        strings = getPersonalizedLessonFilterLanguagesStringsUseCase
            .execute(appLanguage: appLanguage)
    }
}

// MARK: - Inputs

extension PersonalizedLessonFilterLanguageSelectionViewModel {
    
    @objc func backTapped() {
        
        stepEmitter.emit(step: AppFlowStep.backTappedFromPersonalizedLessonLanguageFilter)
    }
    
    func languageTapped(languageId: String) {
        
        self.selectedLanguageId = languageId
        
        let setUserPersonalizedLessonFilterLanguageUseCase: SetUserPersonalizedLessonFilterLanguageUseCase = self.setUserPersonalizedLessonFilterLanguageUseCase
        
        Task.detached {
            
            try await setUserPersonalizedLessonFilterLanguageUseCase
                .execute(languageId: languageId)
        }
        
        stepEmitter.emit(step: AppFlowStep.languageTappedFromPersonalizedLanguageFilter)
    }
}
