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
    
    private let getAppLanguagesListUseCase: GetAppLanguagesListUseCase
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    private let searchAppLanguageInAppLanguagesListUseCase: SearchAppLanguageInAppLanguagesListUseCase
    private let searchTextPublisher: CurrentValueSubject<String, Never> = CurrentValueSubject("")
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var allAppLanguages: [AppLanguageListItemDomainModel] = Array()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var appLanguageSearchResults: [AppLanguageListItemDomainModel] = Array()
    @Published var navTitle: String = ""
    
    init(flowDelegate: FlowDelegate, getAppLanguagesListUseCase: GetAppLanguagesListUseCase, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, searchAppLanguageInAppLanguagesListUseCase: SearchAppLanguageInAppLanguagesListUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getAppLanguagesListUseCase = getAppLanguagesListUseCase
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.searchAppLanguageInAppLanguagesListUseCase = searchAppLanguageInAppLanguagesListUseCase
                
        getInterfaceStringInAppLanguageUseCase
            .observeStringChangedPublisher(id: AppLanguageStringKeys.AppLanguages.navTitle.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: &$navTitle)
        
        getAppLanguagesListUseCase.observeAppLanguagesListPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (appLanguagesList: [AppLanguageListItemDomainModel]) in
                
                self?.allAppLanguages = appLanguagesList
                self?.setSearchResults()
            }
            .store(in: &cancellables)
        
        searchTextPublisher
            .sink { [weak self] searchText in
                
                self?.setSearchResults()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Private

extension AppLanguagesViewModel {
    
    private func setSearchResults() {
        
        appLanguageSearchResults = searchAppLanguageInAppLanguagesListUseCase.getSearchResults(
            for: searchTextPublisher.value,
            searchingIn: allAppLanguages
        )
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
            searchTextPublisher: searchTextPublisher,
            getInterfaceStringInAppLanguageUseCase: getInterfaceStringInAppLanguageUseCase
        )
    }
}
