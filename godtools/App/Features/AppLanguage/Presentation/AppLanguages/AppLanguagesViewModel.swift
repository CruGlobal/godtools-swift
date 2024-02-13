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
            .assign(to: &$appLanguage)
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> in
                return getAppLanguagesListUseCase
                    .getAppLanguagesListPublisher(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .assign(to: &$appLanguagesList)
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewAppLanguagesDomainModel, Never> in
                return viewAppLanguagesUseCase
                    .viewPublisher(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: ViewAppLanguagesDomainModel) in
                
                self?.navTitle = domainModel.interfaceStrings.navTitle
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $searchText.eraseToAnyPublisher(),
            $appLanguagesList.eraseToAnyPublisher()
        )
        .flatMap({ (searchText: String, appLanguagesList: [AppLanguageListItemDomainModel]) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> in
            return searchAppLanguageInAppLanguagesListUseCase
                .getSearchResultsPublisher(searchText: searchText, appLanguagesList: appLanguagesList)
                .eraseToAnyPublisher()
        })
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
        
        return SearchBarViewModel(
            getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase,
            viewSearchBarUseCase: viewSearchBarUseCase
        )
    }
}
