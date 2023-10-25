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
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var confirmLanguageText: String = ""
    @Published var translatedConfirmLanguageText: String = ""
    @Published var changeLanguageButtonTitle: String = ""
    @Published var nevermindButtonTitle: String = ""

    init(selectedLanguage: AppLanguageListItemDomainModel, getConfirmAppLanguageInterfaceStringsUseCase: GetConfirmAppLanguageInterfaceStringsUseCase, flowDelegate: FlowDelegate?) {
        
        self.selectedLanguage = selectedLanguage
        self.flowDelegate = flowDelegate
        
        getConfirmAppLanguageInterfaceStringsUseCase.getStringsPublisher(for: selectedLanguage.languageCode)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] stringsDomainModel in
                
                self?.confirmLanguageText = stringsDomainModel.messageInNewlySelectedLanguage
                self?.translatedConfirmLanguageText = stringsDomainModel.messageInCurrentLanguage

                self?.changeLanguageButtonTitle = stringsDomainModel.changeLanguageButtonText
                self?.nevermindButtonTitle = stringsDomainModel.nevermindButtonText
            }
            .store(in: &cancellables)
    }
}

// MARK: - Inputs

extension ConfirmAppLanguageViewModel {
    
    func confirmLanguageButtonTapped() {
        
        flowDelegate?.navigate(step: .appLanguageChangeConfirmed(appLanguage: selectedLanguage))
    }
    
    func nevermindButtonTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromConfirmAppLanguageChange)
    }
}
