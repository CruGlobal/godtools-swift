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
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    private let getInterfaceStringRepositoryInterface: GetInterfaceStringForLanguageRepositoryInterface
    private let localeLanguageName: LocaleLanguageName
    
    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, getInterfaceStringRepositoryInterface: GetInterfaceStringForLanguageRepositoryInterface, localeLanguageName: LocaleLanguageName) {
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.getInterfaceStringRepositoryInterface = getInterfaceStringRepositoryInterface
        self.localeLanguageName = localeLanguageName
    }
    
    func getStringsPublisher(for selectedLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<ConfirmAppLanguageInterfaceStringsDomainModel, Never> {
        
        return Publishers.CombineLatest4(
            getMessageInNewlySelectedLanguagePublisher(selectedLanguage: selectedLanguage),
            getMessageInCurrentLanguagePublisher(selectedLanguage: selectedLanguage),
            getChangeLanguageButtonTextPublisher(selectedLanguage: selectedLanguage),
            getNevermindButtonTextPublisher(selectedLanguage: selectedLanguage)
        )
        .flatMap { messageInNewlySelectedLanguage, messageInCurrenttLanguage, changeLanguageButtonText, nevermindButtonText in
            
            let domainModel = ConfirmAppLanguageInterfaceStringsDomainModel(
                messageInNewlySelectedLanguage: messageInNewlySelectedLanguage,
                messageInCurrentLanguage: messageInCurrenttLanguage,
                changeLanguageButtonText: changeLanguageButtonText,
                nevermindButtonText: nevermindButtonText
            )
            
            return Just(domainModel)
        }
        .eraseToAnyPublisher()
    }
    
    private func getMessageInNewlySelectedLanguagePublisher(selectedLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<NSAttributedString, Never> {
        
        return getAttributedMessageStringPublisher(selectedLanguage: selectedLanguage, translatedInLanguage: selectedLanguage)
    }
    
    private func getMessageInCurrentLanguagePublisher(selectedLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<NSAttributedString, Never> {
        
        return getCurrentAppLanguageUseCase.getLanguagePublisher()
            .flatMap { currentAppLanguage in
                
                return self.getAttributedMessageStringPublisher(selectedLanguage: selectedLanguage, translatedInLanguage: currentAppLanguage)
            }
            .eraseToAnyPublisher()
    }
    
    private func getAttributedMessageStringPublisher(selectedLanguage: AppLanguageCodeDomainModel, translatedInLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<NSAttributedString, Never> {
        
        return getInterfaceStringRepositoryInterface.getStringPublisher(languageCode: translatedInLanguage, stringId: "languageSettings.confirmAppLanguage.message")
            .flatMap { formatString in
                
                let languageName = self.localeLanguageName.getDisplayName(forLanguageCode: selectedLanguage, translatedInLanguageCode: translatedInLanguage) ?? ""
                let languageNameAttributed = NSAttributedString(
                    string: languageName,
                    attributes: [NSAttributedString.Key.foregroundColor: ColorPalette.gtBlue.uiColor]
                )
                
                let attributedString = NSAttributedString(format: NSAttributedString(string: formatString), args: languageNameAttributed)
                                
                return Just(attributedString)
            }
            .eraseToAnyPublisher()
    }
    
    private func getChangeLanguageButtonTextPublisher(selectedLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<String, Never> {
        
        return getInterfaceStringRepositoryInterface.getStringPublisher(languageCode: selectedLanguage, stringId: "languageSettings.confirmAppLanguage.changeLanguageButton.title")
    }
    
    private func getNevermindButtonTextPublisher(selectedLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<String, Never> {
        
        return getInterfaceStringRepositoryInterface.getStringPublisher(languageCode: selectedLanguage, stringId: "languageSettings.confirmAppLanguage.nevermindButton.title")
    }
}
