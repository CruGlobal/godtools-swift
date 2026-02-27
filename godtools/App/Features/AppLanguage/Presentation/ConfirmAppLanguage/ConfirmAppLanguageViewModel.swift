//
//  ConfirmAppLanguageViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 10/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class ConfirmAppLanguageViewModel: ObservableObject {
    
    private let selectedLanguage: AppLanguageListItemDomainModel
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getConfirmAppLanguageStringsUseCase: GetConfirmAppLanguageStringsUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published private(set) var strings = ConfirmAppLanguageStringsDomainModel.emptyValue
    
    init(selectedLanguage: AppLanguageListItemDomainModel, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getConfirmAppLanguageStringsUseCase: GetConfirmAppLanguageStringsUseCase, flowDelegate: FlowDelegate?) {
        
        self.selectedLanguage = selectedLanguage
        self.flowDelegate = flowDelegate
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getConfirmAppLanguageStringsUseCase = getConfirmAppLanguageStringsUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getConfirmAppLanguageStringsUseCase
                    .execute(appLanguage: appLanguage, selectedLanguage: selectedLanguage.language)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: ConfirmAppLanguageStringsDomainModel) in
                
                self?.strings = strings
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}

// MARK: - Inputs

extension ConfirmAppLanguageViewModel {
    
    func confirmLanguageButtonTapped() {
        flowDelegate?.navigate(step: .appLanguageChangeConfirmed(appLanguage: selectedLanguage))
    }
    
    func nevermindButtonTapped() {
        flowDelegate?.navigate(step: .nevermindTappedFromConfirmAppLanguageChange)
    }
    
    @objc func closeTapped() {
        flowDelegate?.navigate(step: .backTappedFromConfirmAppLanguageChange)
    }
}
