//
//  LessonFilterLanguageSelectionViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine
import Flow

@MainActor
final class LessonFilterLanguageSelectionViewModel: ObservableObject {
        
    private let stepEmitter: FlowStepEmitter
    private let getLessonFilterLanguagesStringsUseCase: GetLessonFilterLanguagesStringsUseCase
    private let getLessonFilterLanguagesUseCase: GetLessonFilterLanguagesUseCase
    private let getUserLessonFilterLanguageUseCase: GetUserLessonFilterLanguageUseCase
    private let setUserLessonFilterLanguageUseCase: SetUserLessonFilterLanguageUseCase
    private let getSearchBarStringsUseCase: GetSearchBarStringsUseCase
    private let searchLessonFilterLanguagesUseCase: SearchLessonFilterLanguagesUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage = AppLanguageDomainModel.english
    @Published private var allLanguages: [LessonFilterLanguageDomainModel] = Array()
    
    @Published private(set) var searchBarStrings = SearchBarStringsDomainModel.emptyValue
    @Published private(set) var strings = LessonFilterLanguagesStringsDomainModel.emptyValue
    @Published private(set) var languageSearchResults: [LessonFilterLanguageDomainModel] = Array()
    @Published private(set) var selectedLanguage: LessonFilterLanguageDomainModel?
    
    @Published var searchText: String = ""
    
    init(
        stepEmitter: FlowStepEmitter,
        getLessonFilterLanguagesStringsUseCase: GetLessonFilterLanguagesStringsUseCase,
        getLessonFilterLanguagesUseCase: GetLessonFilterLanguagesUseCase,
        getUserLessonFilterLanguageUseCase: GetUserLessonFilterLanguageUseCase,
        setUserLessonFilterLanguageUseCase: SetUserLessonFilterLanguageUseCase,
        getSearchBarStringsUseCase: GetSearchBarStringsUseCase,
        searchLessonFilterLanguagesUseCase: SearchLessonFilterLanguagesUseCase,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.getLessonFilterLanguagesStringsUseCase = getLessonFilterLanguagesStringsUseCase
        self.getLessonFilterLanguagesUseCase = getLessonFilterLanguagesUseCase
        self.getUserLessonFilterLanguageUseCase = getUserLessonFilterLanguageUseCase
        self.setUserLessonFilterLanguageUseCase = setUserLessonFilterLanguageUseCase
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
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getUserLessonFilterLanguageUseCase
                    .execute(
                        appLanguage: appLanguage
                    )
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (languageFilter: LessonFilterLanguageDomainModel?) in
                
                self?.selectedLanguage = languageFilter
            })
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $searchText,
            $allLanguages
        )
        .map { (searchText: String, languages: [LessonFilterLanguageDomainModel]) in
            
            searchLessonFilterLanguagesUseCase
                .execute(searchText: searchText, lessonFilterLanguages: languages)
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
    
    func languageTapped(language: LessonFilterLanguageDomainModel) {
        
        selectedLanguage = language
        
        let setUserLessonFilterLanguageUseCase: SetUserLessonFilterLanguageUseCase = self.setUserLessonFilterLanguageUseCase
        
        Task.detached {
            
            try await setUserLessonFilterLanguageUseCase
                .execute(language: language)
        }
        
        stepEmitter.emit(step: AppFlowStep.languageTappedFromLessonLanguageFilter)
    }
}
