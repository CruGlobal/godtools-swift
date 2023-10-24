//
//  GetConfirmAppLanguageInterfaceStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 10/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetConfirmAppLanguageInterfaceStringsUseCase {
    
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    private let getInterfaceStringRepositoryInterface: GetInterfaceStringForLanguageRepositoryInterface
    private let localeLanguageName: LocaleLanguageName
    
    init(getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, getInterfaceStringRepositoryInterface: GetInterfaceStringForLanguageRepositoryInterface, localeLanguageName: LocaleLanguageName) {
        
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.getInterfaceStringRepositoryInterface = getInterfaceStringRepositoryInterface
        self.localeLanguageName = localeLanguageName
    }
    
    func getStringsPublisher(for selectedLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<ConfirmAppLanguageInterfaceStringsDomainModel, Never> {
        
        return getMessageInNewlySelectedLanguagePublisher(selectedLanguage: selectedLanguage)
            .flatMap { message in
                
                let domainModel = ConfirmAppLanguageInterfaceStringsDomainModel(messageInNewlySelectedLanguage: message, messageInCurrentLanguage: message, changeLanguageButtonText: "Change Lang", nevermindButtonText: "Nvm")
                
                return Just(domainModel)
            }
            .eraseToAnyPublisher()
    }
    
    private func getMessageInNewlySelectedLanguagePublisher(selectedLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<String, Never> {
        
        return getInterfaceStringRepositoryInterface.getStringPublisher(languageCode: selectedLanguage, stringId: "languageSettings.confirmAppLanguage.message")
            .flatMap { formatString in
                
                let languageName = self.localeLanguageName.getDisplayName(forLanguageCode: selectedLanguage, translatedInLanguageCode: selectedLanguage) ?? ""
                
                let str = String.localizedStringWithFormat(formatString, languageName)
                                
                return Just(str)
            }
            .eraseToAnyPublisher()
    }
}
