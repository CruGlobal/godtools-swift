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
    private let localizationServices: LocalizationServices
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    private let searchTextPublisher: CurrentValueSubject<String, Never> = CurrentValueSubject("")
    
    @Published var appLanguages: [AppLanguageListItemDomainModel] = Array()
    
    init(flowDelegate: FlowDelegate, getAppLanguagesListUseCase: GetAppLanguagesListUseCase, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.getAppLanguagesListUseCase = getAppLanguagesListUseCase
        self.localizationServices = localizationServices
        
        appLanguages = getAppLanguagesListUseCase.getAppLanguagesList()
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
            localizationServices: localizationServices
        )
    }
}
