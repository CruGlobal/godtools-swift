//
//  AppLanguagesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class AppLanguagesViewModel: ObservableObject {
    
    private let getAppLanguagesStringsUseCase: GetAppLanguagesStringsUseCase
    private let searchAppLanguageInAppLanguagesListUseCase: SearchAppLanguageInAppLanguagesListUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getAppLanguagesListUseCase: GetAppLanguagesListUseCase
    private let viewSearchBarUseCase: ViewSearchBarUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    private lazy var searchBarViewModel = SearchBarViewModel(getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, viewSearchBarUseCase: viewSearchBarUseCase)
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var appLanguagesList: [AppLanguageListItemDomainModel] = Array()
    
    @Published private(set) var strings = AppLanguagesStringsDomainModel.emptyValue
    
    @Published var searchText: String = ""
    @Published var appLanguageSearchResults: [AppLanguageListItemDomainModel] = Array()
    
    init(flowDelegate: FlowDelegate, getAppLanguagesStringsUseCase: GetAppLanguagesStringsUseCase, searchAppLanguageInAppLanguagesListUseCase: SearchAppLanguageInAppLanguagesListUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getAppLanguagesListUseCase: GetAppLanguagesListUseCase, viewSearchBarUseCase: ViewSearchBarUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getAppLanguagesStringsUseCase = getAppLanguagesStringsUseCase
        self.searchAppLanguageInAppLanguagesListUseCase = searchAppLanguageInAppLanguagesListUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getAppLanguagesListUseCase = getAppLanguagesListUseCase
        self.viewSearchBarUseCase = viewSearchBarUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                getAppLanguagesListUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (appLanguages: [AppLanguageListItemDomainModel]) in
                
                self?.appLanguagesList = appLanguages
            })
            .store(in: &cancellables)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                getAppLanguagesStringsUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: AppLanguagesStringsDomainModel) in
                
                self?.strings = strings
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $searchText,
            $appLanguagesList.dropFirst()
        )
        .flatMap { (searchText: String, appLanguagesList: [AppLanguageListItemDomainModel]) in
            
            searchAppLanguageInAppLanguagesListUseCase
                .execute(searchText: searchText, appLanguagesList: appLanguagesList)
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
