//
//  AppLanguagesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class AppLanguagesViewModel: ObservableObject {
    
    private let viewAppLanguagesUseCase: ViewAppLanguagesUseCase
    private let searchAppLanguageInAppLanguagesListUseCase: SearchAppLanguageInAppLanguagesListUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getAppLanguagesListUseCase: GetAppLanguagesListUseCase
    private let viewSearchBarUseCase: ViewSearchBarUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    private lazy var searchBarViewModel = SearchBarViewModel(getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, viewSearchBarUseCase: viewSearchBarUseCase)
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var appLanguagesList: [AppLanguageListItemDomainModel] = Array()
    
    @Published var searchText: String = ""
    @Published var appLanguageSearchResults: [AppLanguageListItemDomainModel] = Array()
    @Published var navTitle: String = ""
    
    init(flowDelegate: FlowDelegate, viewAppLanguagesUseCase: ViewAppLanguagesUseCase, searchAppLanguageInAppLanguagesListUseCase: SearchAppLanguageInAppLanguagesListUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getAppLanguagesListUseCase: GetAppLanguagesListUseCase, viewSearchBarUseCase: ViewSearchBarUseCase) {
        
        self.flowDelegate = flowDelegate
        self.viewAppLanguagesUseCase = viewAppLanguagesUseCase
        self.searchAppLanguageInAppLanguagesListUseCase = searchAppLanguageInAppLanguagesListUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getAppLanguagesListUseCase = getAppLanguagesListUseCase
        self.viewSearchBarUseCase = viewSearchBarUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                getAppLanguagesListUseCase
                    .getAppLanguagesListPublisher(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguagesList)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                viewAppLanguagesUseCase
                    .viewPublisher(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: ViewAppLanguagesDomainModel) in
                
                self?.navTitle = domainModel.interfaceStrings.navTitle
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $searchText,
            $appLanguagesList.dropFirst()
        )
        .flatMap { (searchText: String, appLanguagesList: [AppLanguageListItemDomainModel]) in
            
            searchAppLanguageInAppLanguagesListUseCase
                .getSearchResultsPublisher(for: searchText, in: appLanguagesList)
        }
        .receive(on: DispatchQueue.main)
        .assign(to: &$appLanguageSearchResults)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}

// MARK: - Inputs

extension AppLanguagesViewModel {
    
    @objc func backTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromAppLanguages)
    }
    
    func appLanguageTapped(appLanguage: AppLanguageListItemDomainModel) {
        
        flowDelegate?.navigate(step: .appLanguageTappedFromAppLanguages(appLanguage: appLanguage))
    }
    
    func getSearchBarViewModel() -> SearchBarViewModel {
        
        return searchBarViewModel
    }
}
