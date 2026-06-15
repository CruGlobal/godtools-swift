//
//  ConfirmAppLanguageViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 10/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class ConfirmAppLanguageViewModel: ObservableObject {
    
    private let stepEmitter: FlowStepEmitter
    private let selectedLanguage: AppLanguageListItemDomainModel
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getConfirmAppLanguageStringsUseCase: GetConfirmAppLanguageStringsUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage = AppLanguageDomainModel.english
    
    @Published private(set) var strings = ConfirmAppLanguageStringsDomainModel.emptyValue
    
    init(stepEmitter: FlowStepEmitter, selectedLanguage: AppLanguageListItemDomainModel, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getConfirmAppLanguageStringsUseCase: GetConfirmAppLanguageStringsUseCase) {
        
        self.stepEmitter = stepEmitter
        self.selectedLanguage = selectedLanguage
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getConfirmAppLanguageStringsUseCase = getConfirmAppLanguageStringsUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
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
        stepEmitter.emit(step: AppFlowStep.appLanguageChangeConfirmed(appLanguage: selectedLanguage))
    }
    
    func nevermindButtonTapped() {
        stepEmitter.emit(step: AppFlowStep.nevermindTappedFromConfirmAppLanguageChange)
    }
    
    @objc func closeTapped() {
        stepEmitter.emit(step: AppFlowStep.backTappedFromConfirmAppLanguageChange)
    }
}
