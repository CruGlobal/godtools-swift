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
    
    private let viewSearchBarUseCase: ViewSearchBarUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private lazy var searchBarViewModel = SearchBarViewModel(getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, viewSearchBarUseCase: viewSearchBarUseCase)
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var appLanguagesList: [AppLanguageListItemDomainModel] = Array()
    
    @Published var searchText: String = ""
    @Published var appLanguageSearchResults: [AppLanguageListItemDomainModel] = Array()
    @Published var navTitle: String = ""
    
    init(viewSearchBarUseCase: ViewSearchBarUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase) {
        self.viewSearchBarUseCase = viewSearchBarUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
//        $appLanguage
//            .dropFirst()
//            .map { (appLanguage: AppLanguageDomainModel) in
//
//                getAppLanguagesListUseCase
//                    .getAppLanguagesListPublisher(appLanguage: appLanguage)
//            }
//            .switchToLatest()
//            .receive(on: DispatchQueue.main)
//            .assign(to: &$appLanguagesList)
        
//        $appLanguage
//            .dropFirst()
//            .map { (appLanguage: AppLanguageDomainModel) in
//                viewAppLanguagesUseCase
//                    .viewPublisher(appLanguage: appLanguage)
//            }
//            .switchToLatest()
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] (domainModel: ViewAppLanguagesDomainModel) in
//                
//                self?.navTitle = domainModel.interfaceStrings.navTitle
//            }
//            .store(in: &cancellables)
        
//        Publishers.CombineLatest(
//            $searchText,
//            $appLanguagesList.dropFirst()
//        )
//        .flatMap { (searchText: String, appLanguagesList: [AppLanguageListItemDomainModel]) in
//            
//            searchAppLanguageInAppLanguagesListUseCase
//                .getSearchResultsPublisher(for: searchText, in: appLanguagesList)
//        }
//        .receive(on: DispatchQueue.main)
//        .assign(to: &$appLanguageSearchResults)
    }
}

// MARK: - Inputs

extension LessonFilterLanguageSelectionViewModel {
    
    @objc func backTapped() {
        
//        flowDelegate?.navigate(step: .backTappedFromAppLanguages)
    }
    
    func appLanguageTapped(appLanguage: AppLanguageListItemDomainModel) {
        
//        flowDelegate?.navigate(step: .appLanguageTappedFromAppLanguages(appLanguage: appLanguage))
    }
    
    func getSearchBarViewModel() -> SearchBarViewModel {
        
        return searchBarViewModel
    }
    
}
