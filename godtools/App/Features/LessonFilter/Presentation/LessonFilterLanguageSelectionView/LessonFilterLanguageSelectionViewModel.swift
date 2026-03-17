//
//  LessonFilterLanguageSelectionViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class LessonFilterLanguageSelectionViewModel: ObservableObject {
    
    private static var staticCancellables: Set<AnyCancellable> = Set()
    
    private let getLessonFilterLanguagesStringsUseCase: GetLessonFilterLanguagesStringsUseCase
    private let getLessonFilterLanguagesUseCase: GetLessonFilterLanguagesUseCase
    private let getUserLessonFiltersUseCase: GetUserLessonFiltersUseCase
    private let storeUserLessonFiltersUseCase: StoreUserLessonFiltersUseCase
    private let viewSearchBarUseCase: ViewSearchBarUseCase
    private let searchLessonFilterLanguagesUseCase: SearchLessonFilterLanguagesUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    private weak var flowDelegate: FlowDelegate?
    private lazy var searchBarViewModel = SearchBarViewModel(getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, viewSearchBarUseCase: viewSearchBarUseCase)
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var allLanguages: [LessonFilterLanguageDomainModel] = Array()
    
    @Published private(set) var strings = LessonFilterLanguagesStringsDomainModel.emptyValue
    
    @Published var searchText: String = ""
    @Published var languageSearchResults: [LessonFilterLanguageDomainModel] = Array()
    @Published var selectedLanguage: LessonFilterLanguageDomainModel?
    
    init(getLessonFilterLanguagesStringsUseCase: GetLessonFilterLanguagesStringsUseCase, getLessonFilterLanguagesUseCase: GetLessonFilterLanguagesUseCase, getUserLessonFiltersUseCase: GetUserLessonFiltersUseCase, storeUserLessonFiltersUseCase: StoreUserLessonFiltersUseCase, viewSearchBarUseCase: ViewSearchBarUseCase, searchLessonFilterLanguagesUseCase: SearchLessonFilterLanguagesUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, flowDelegate: FlowDelegate) {
        
        self.getLessonFilterLanguagesStringsUseCase = getLessonFilterLanguagesStringsUseCase
        self.getLessonFilterLanguagesUseCase = getLessonFilterLanguagesUseCase
        self.getUserLessonFiltersUseCase = getUserLessonFiltersUseCase
        self.storeUserLessonFiltersUseCase = storeUserLessonFiltersUseCase
        self.viewSearchBarUseCase = viewSearchBarUseCase
        self.searchLessonFilterLanguagesUseCase = searchLessonFilterLanguagesUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.flowDelegate = flowDelegate
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getLessonFilterLanguagesStringsUseCase
                    .execute(
                        appLanguage: appLanguage
                    )
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (strings: LessonFilterLanguagesStringsDomainModel) in
                
                self?.strings = strings
            })
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
}

// MARK: - Inputs

extension LessonFilterLanguageSelectionViewModel {
    
    @objc func backTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromLessonLanguageFilter)
    }
    
    func languageTapped(_ language: LessonFilterLanguageDomainModel) {
        
        selectedLanguage = language
        
        storeUserLessonFiltersUseCase
            .execute(languageFilter: language)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            }
            .store(in: &LessonFilterLanguageSelectionViewModel.staticCancellables)
        
        flowDelegate?.navigate(step: .languageTappedFromLessonLanguageFilter)
    }
    
    func getSearchBarViewModel() -> SearchBarViewModel {
        
        return searchBarViewModel
    }
}
