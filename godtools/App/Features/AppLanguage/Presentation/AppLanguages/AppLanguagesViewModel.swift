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
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    private let searchTextPublisher: CurrentValueSubject<String, Never> = CurrentValueSubject("")
    private var allAppLanguages: [AppLanguageListItemDomainModel] = Array()
    
    @Published var appLanguages: [AppLanguageListItemDomainModel] = Array()
    @Published var navTitle: String = ""
    
    init(flowDelegate: FlowDelegate, getAppLanguagesListUseCase: GetAppLanguagesListUseCase, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getAppLanguagesListUseCase = getAppLanguagesListUseCase
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        
        appLanguages = allAppLanguages
        
        getInterfaceStringInAppLanguageUseCase
            .observeStringChangedPublisher(id: "languageSettings.appLanguage.title")
            .receive(on: DispatchQueue.main)
            .assign(to: &$navTitle)
        
        getAppLanguagesListUseCase.observeAppLanguagesListPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (appLanguagesList: [AppLanguageListItemDomainModel]) in
                
                self?.allAppLanguages = appLanguagesList
                self?.appLanguages = appLanguagesList
            }
            .store(in: &cancellables)
        
        searchTextPublisher
            .sink { [weak self] searchText in
                guard let self = self else { return }
                
                if searchText.isEmpty {
                    self.appLanguages = self.allAppLanguages
                    
                } else {
                    
                    self.appLanguages = self.allAppLanguages.filter { $0.languageNameTranslatedInCurrentAppLanguage.value.contains(searchText) }
                }
            }
            .store(in: &cancellables)
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
