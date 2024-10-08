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
    
    @Published var messageInNewlySelectedLanguageHighlightModel: ConfirmAppLanguageHighlightStringDomainModel = ConfirmAppLanguageHighlightStringDomainModel.emptyStrings()
    @Published var messageInCurrentLanguageHighlightModel: ConfirmAppLanguageHighlightStringDomainModel = ConfirmAppLanguageHighlightStringDomainModel.emptyStrings()
    @Published var changeLanguageButtonTitle: String = ""
    @Published var nevermindButtonTitle: String = ""

    init(selectedLanguage: AppLanguageListItemDomainModel, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewConfirmAppLanguageUseCase: ViewConfirmAppLanguageUseCase, flowDelegate: FlowDelegate?) {
        
        self.selectedLanguage = selectedLanguage
        self.flowDelegate = flowDelegate
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewConfirmAppLanguageUseCase = viewConfirmAppLanguageUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                viewConfirmAppLanguageUseCase
                    .viewPublisher(appLanguage: appLanguage, selectedLanguage: selectedLanguage.language)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] domainModel in
                guard let self = self else { return }
                let interfaceStrings = domainModel.interfaceStrings
                
                self.messageInNewlySelectedLanguageHighlightModel = interfaceStrings.messageInNewlySelectedLanguageHighlightModel
                self.messageInCurrentLanguageHighlightModel = interfaceStrings.messageInCurrentLanguageHighlightModel
                self.changeLanguageButtonTitle = interfaceStrings.changeLanguageButtonText
                self.nevermindButtonTitle = interfaceStrings.nevermindButtonText
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
