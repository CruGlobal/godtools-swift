//
//  LessonFilterLanguageSelectionViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class LessonFilterLanguageSelectionViewModel: ObservableObject {
    
    private let viewLessonFilterLanguagesUseCase: ViewLessonFilterLanguagesUseCase
    private let viewSearchBarUseCase: ViewSearchBarUseCase
    private let searchLessonFilterLanguagesUseCase: SearchLessonFilterLanguagesUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    private weak var flowDelegate: FlowDelegate?
    
    private lazy var searchBarViewModel = SearchBarViewModel(getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, viewSearchBarUseCase: viewSearchBarUseCase)
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var allLanguages: [LessonLanguageFilterDomainModel] = Array()
    
    @Published var searchText: String = ""
    @Published var languageSearchResults: [LessonLanguageFilterDomainModel] = Array()
    @Published var selectedLanguage: LessonLanguageFilterDomainModel = LessonLanguageFilterDomainModel(languageId: "", languageName: "English", translatedName: "", lessonsAvailableText: "")
    @Published var navTitle: String = ""
    
    init(viewLessonFilterLanguagesUseCase: ViewLessonFilterLanguagesUseCase, viewSearchBarUseCase: ViewSearchBarUseCase, searchLessonFilterLanguagesUseCase: SearchLessonFilterLanguagesUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, flowDelegate: FlowDelegate) {
        self.viewLessonFilterLanguagesUseCase = viewLessonFilterLanguagesUseCase
        self.viewSearchBarUseCase = viewSearchBarUseCase
        self.searchLessonFilterLanguagesUseCase = searchLessonFilterLanguagesUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.flowDelegate = flowDelegate
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                viewLessonFilterLanguagesUseCase.viewPublisher(translatedInAppLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: ViewLessonFilterLanguagesDomainModel) in
                
                self?.navTitle = domainModel.interfaceStrings.navTitle
                self?.allLanguages = domainModel.languageFilters
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $searchText,
            $allLanguages
        )
        .flatMap { (searchText: String, languages: [LessonLanguageFilterDomainModel]) in
            
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
    
    func appLanguageTapped(appLanguage: AppLanguageListItemDomainModel) {
        
//        flowDelegate?.navigate(step: .appLanguageTappedFromAppLanguages(appLanguage: appLanguage))
    }
    
    func getSearchBarViewModel() -> SearchBarViewModel {
        
        return searchBarViewModel
    }
    
}
