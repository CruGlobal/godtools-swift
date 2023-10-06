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
    
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    private let getAppLanguagesListUseCase: GetAppLanguagesListUseCase
    private let searchAppLanguageInAppLanguagesListUseCase: SearchAppLanguageInAppLanguagesListUseCase
    private let searchTextPublisher: CurrentValueSubject<String, Never> = CurrentValueSubject("")
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var appLanguageSearchResults: [AppLanguageListItemDomainModel] = Array()
    @Published var navTitle: String = ""
    @Published var searchText: String = "" {
        didSet {
            searchTextPublisher.send(searchText)
        }
    }
    
    init(flowDelegate: FlowDelegate, getAppLanguagesListUseCase: GetAppLanguagesListUseCase, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, searchAppLanguageInAppLanguagesListUseCase: SearchAppLanguageInAppLanguagesListUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.getAppLanguagesListUseCase = getAppLanguagesListUseCase
        self.searchAppLanguageInAppLanguagesListUseCase = searchAppLanguageInAppLanguagesListUseCase
                           
        getInterfaceStringInAppLanguageUseCase
            .observeStringChangedPublisher(id: AppLanguageStringKeys.AppLanguages.navTitle.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: &$navTitle)
        
        searchAppLanguageInAppLanguagesListUseCase
            .getSearchResultsPublisher(for: searchTextPublisher.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguageSearchResults)
        
        /*
        searchAppLanguageInAppLanguagesListUseCase
            .getSearchResultsPublisher(for: searchText.publisher
                .reduce("") { (previousResult, value) in
                    return previousResult + String(value)
                }
                .eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguageSearchResults)*/
    }
}

// MARK: - Inputs

extension AppLanguagesViewModel {
    
    @objc func backTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromAppLanguages)
    }
    
    func searchInputChanged(searchText: AnyPublisher<String, Never>) {
        
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
