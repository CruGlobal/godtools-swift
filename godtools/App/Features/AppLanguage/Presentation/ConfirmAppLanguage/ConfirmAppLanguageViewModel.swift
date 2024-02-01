//
//  ConfirmAppLanguageViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 10/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ConfirmAppLanguageViewModel: ObservableObject {
    
    private let selectedLanguage: AppLanguageListItemDomainModel
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewConfirmAppLanguageUseCase: ViewConfirmAppLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published var messageInNewlySelectedLanguage: NSAttributedString = NSAttributedString()
    @Published var messageInCurrentLanguage: NSAttributedString = NSAttributedString()
    @Published var changeLanguageButtonTitle: String = ""
    @Published var nevermindButtonTitle: String = ""

    init(selectedLanguage: AppLanguageListItemDomainModel, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewConfirmAppLanguageUseCase: ViewConfirmAppLanguageUseCase, flowDelegate: FlowDelegate?) {
        
        self.selectedLanguage = selectedLanguage
        self.flowDelegate = flowDelegate
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewConfirmAppLanguageUseCase = viewConfirmAppLanguageUseCase
        
        getCurrentAppLanguageUseCase.getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap { appLanguage in
                
                return viewConfirmAppLanguageUseCase.viewPublisher(appLanguage: appLanguage, selectedLanguage: selectedLanguage.language)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] domainModel in
                
                let interfaceStrings = domainModel.interfaceStrings
                
                self?.messageInNewlySelectedLanguage = interfaceStrings.messageInNewlySelectedLanguage
                self?.messageInCurrentLanguage = interfaceStrings.messageInCurrentLanguage
                self?.changeLanguageButtonTitle = interfaceStrings.changeLanguageButtonText
                self?.nevermindButtonTitle = interfaceStrings.nevermindButtonText
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
