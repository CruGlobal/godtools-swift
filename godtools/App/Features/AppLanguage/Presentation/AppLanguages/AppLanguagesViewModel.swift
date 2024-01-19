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
    private let searchAppLanguageInAppLanguagesListUseCase: SearchAppLanguageInAppLanguagesListUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewSearchBarUseCase: ViewSearchBarUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var searchText: String = ""
    @Published var appLanguageSearchResults: [AppLanguageListItemDomainModel] = Array()
    @Published var navTitle: String = ""
    
    init(flowDelegate: FlowDelegate, getAppLanguagesListUseCase: GetAppLanguagesListUseCase, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, searchAppLanguageInAppLanguagesListUseCase: SearchAppLanguageInAppLanguagesListUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewSearchBarUseCase: ViewSearchBarUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.searchAppLanguageInAppLanguagesListUseCase = searchAppLanguageInAppLanguagesListUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewSearchBarUseCase = viewSearchBarUseCase
                
        getInterfaceStringInAppLanguageUseCase
            .getStringPublisher(id: AppLanguageStringKeys.AppLanguages.navTitle.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: &$navTitle)
                
        searchAppLanguageInAppLanguagesListUseCase
            .getSearchResultsPublisher(for: $searchText.eraseToAnyPublisher())
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
