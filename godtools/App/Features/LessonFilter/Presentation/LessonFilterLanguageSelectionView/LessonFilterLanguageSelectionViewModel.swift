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
    
    private let viewLessonFilterLanguagesUseCase: ViewLessonFilterLanguagesUseCase
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
    
    @Published var searchText: String = ""
    @Published var languageSearchResults: [LessonFilterLanguageDomainModel] = Array()
    @Published var selectedLanguage: LessonFilterLanguageDomainModel?
    @Published var navTitle: String = ""
    
    init(viewLessonFilterLanguagesUseCase: ViewLessonFilterLanguagesUseCase, getUserLessonFiltersUseCase: GetUserLessonFiltersUseCase, storeUserLessonFiltersUseCase: StoreUserLessonFiltersUseCase, viewSearchBarUseCase: ViewSearchBarUseCase, searchLessonFilterLanguagesUseCase: SearchLessonFilterLanguagesUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, flowDelegate: FlowDelegate) {
        self.viewLessonFilterLanguagesUseCase = viewLessonFilterLanguagesUseCase
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
                
                viewLessonFilterLanguagesUseCase.viewPublisher(translatedInAppLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (domainModel: ViewLessonFilterLanguagesDomainModel) in
                
                self?.navTitle = domainModel.interfaceStrings.navTitle
                self?.allLanguages = domainModel.languageFilters
            })
            .store(in: &cancellables)
        
        $appLanguage
            .dropFirst()
            .map { appLanguage in
            
                getUserLessonFiltersUseCase.getUserToolFiltersPublisher(translatedInAppLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userFilters in
                guard let self = self else { return }
                guard self.selectedLanguage == nil else { return }
                
                if let languageFilter = userFilters.languageFilter {
                    
                    self.selectedLanguage = languageFilter
                }
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $searchText,
            $allLanguages
        )
        .flatMap { (searchText: String, languages: [LessonFilterLanguageDomainModel]) in
            
            searchLessonFilterLanguagesUseCase.getSearchResultsPublisher(for: searchText, in: languages)
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
            .storeLanguageFilterPublisher(language)
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
