//
//  AppLanguagesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class AppLanguagesViewModel: ObservableObject {
    
    private let getAppLanguagesStringsUseCase: GetAppLanguagesStringsUseCase
    private let searchAppLanguageInAppLanguagesListUseCase: SearchAppLanguageInAppLanguagesListUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getAppLanguagesListUseCase: GetAppLanguagesListUseCase
    private let getSearchBarStringsUseCase: GetSearchBarStringsUseCase
    
    private var getAppLanguagesTask: Task<Void, Error>?
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage = AppLanguageDomainModel.english
    @Published private var appLanguagesList: [AppLanguageListItemDomainModel] = Array()
    
    @Published private(set) var searchBarStrings = SearchBarStringsDomainModel.emptyValue
    @Published private(set) var strings = AppLanguagesStringsDomainModel.emptyValue
    
    @Published var searchText: String = ""
    @Published var appLanguageSearchResults: [AppLanguageListItemDomainModel] = Array()
    
    init(flowDelegate: FlowDelegate, getAppLanguagesStringsUseCase: GetAppLanguagesStringsUseCase, searchAppLanguageInAppLanguagesListUseCase: SearchAppLanguageInAppLanguagesListUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getAppLanguagesListUseCase: GetAppLanguagesListUseCase, getSearchBarStringsUseCase: GetSearchBarStringsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getAppLanguagesStringsUseCase = getAppLanguagesStringsUseCase
        self.searchAppLanguageInAppLanguagesListUseCase = searchAppLanguageInAppLanguagesListUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getAppLanguagesListUseCase = getAppLanguagesListUseCase
        self.getSearchBarStringsUseCase = getSearchBarStringsUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (appLanguage: AppLanguageDomainModel) in
                self?.appLanguage = appLanguage
                self?.didSetAppLanguage(appLanguage: appLanguage)
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
        getAppLanguagesTask?.cancel()
    }
    
    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel) {
        
        searchBarStrings = getSearchBarStringsUseCase
            .execute(appLanguage: appLanguage)
        
        strings = getAppLanguagesStringsUseCase
            .execute(appLanguage: appLanguage)
        
        refreshAppLanguagesList(appLanguage: appLanguage)
    }
    
    private func refreshAppLanguagesList(appLanguage: AppLanguageDomainModel) {
        
        getAppLanguagesTask?.cancel()
        
        getAppLanguagesTask = Task {
            appLanguagesList = try await getAppLanguagesListUseCase.execute(appLanguage: appLanguage)
        }
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
}
