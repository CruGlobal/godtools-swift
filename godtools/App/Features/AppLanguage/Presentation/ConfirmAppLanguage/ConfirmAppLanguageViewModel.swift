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
    
    @Published var confirmLanguageText: String = ""
    @Published var translatedConfirmLanguageText: String = ""
    @Published var changeLanguageButtonTitle: String = ""
    @Published var nevermindButtonTitle: String = ""
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(selectedLanguage: AppLanguageListItemDomainModel, getConfirmAppLanguageInterfaceStringsUseCase: GetConfirmAppLanguageInterfaceStringsUseCase) {
        
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
