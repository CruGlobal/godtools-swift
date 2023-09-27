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
    
    private let getAppLanguagesUseCase: GetAppLanguagesUseCase
    private let localizationServices: LocalizationServices
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    private let searchTextPublisher: CurrentValueSubject<String, Never> = CurrentValueSubject("")
    
    @Published var appLanguages: [AppLanguageDomainModel] = Array()
    
    init(flowDelegate: FlowDelegate, getAppLanguagesUseCase: GetAppLanguagesUseCase, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.getAppLanguagesUseCase = getAppLanguagesUseCase
        self.localizationServices = localizationServices
        
        getAppLanguagesUseCase.getAppLanguagesPublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: \.appLanguages, on: self)
            .store(in: &cancellables)
    }
}

// MARK: - Inputs

extension AppLanguagesViewModel {
    
    @objc func backTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromAppLanguages)
    }
    
    func appLanguageTapped(appLanguage: AppLanguageDomainModel) {
        
        flowDelegate?.navigate(step: .appLanguageTappedFromAppLanguages(appLanguage: appLanguage))
    }
    
    func getSearchBarViewModel() -> SearchBarViewModel {
        
        return SearchBarViewModel(
            searchTextPublisher: searchTextPublisher,
            localizationServices: localizationServices
        )
    }
}
