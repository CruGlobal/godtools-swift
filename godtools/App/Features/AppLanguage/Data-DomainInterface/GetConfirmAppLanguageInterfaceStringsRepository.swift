//
//  GetConfirmAppLanguageInterfaceStringsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 1/27/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetConfirmAppLanguageInterfaceStringsRepository: GetConfirmAppLanguageInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    private let localeLanguageName: LocaleLanguageName
    
    init(localizationServices: LocalizationServices, localeLanguageName: LocaleLanguageName) {
        
        self.localizationServices = localizationServices
        self.localeLanguageName = localeLanguageName
    }
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel, selectedLanguage: AppLanguageDomainModel) -> AnyPublisher<ConfirmAppLanguageInterfaceStringsDomainModel, Never> {
        
        let appLanguageLocaleId: String = translateInAppLanguage
        
        let interfaceStrings = ConfirmAppLanguageInterfaceStringsDomainModel(
            messageInNewlySelectedLanguage: getAttributedMessageStringPublisher(selectedLanguage: selectedLanguage, localeId: selectedLanguage),
            messageInCurrentLanguage: getAttributedMessageStringPublisher(selectedLanguage: selectedLanguage, localeId: appLanguageLocaleId),
            changeLanguageButtonText: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageLocaleId, key: "languageSettings.confirmAppLanguage.changeLanguageButton.title"),
            nevermindButtonText: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageLocaleId, key: "languageSettings.confirmAppLanguage.nevermindButton.title")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
    
    private func getAttributedMessageStringPublisher(selectedLanguage: AppLanguageDomainModel, localeId: String) -> NSAttributedString {
        
        let formatString = localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "languageSettings.confirmAppLanguage.message")
        
        let languageName = self.localeLanguageName.getLanguageName(forLanguageCode: selectedLanguage, translatedInLanguageId: localeId) ?? ""
        let languageNameAttributed = NSAttributedString(
            string: languageName,
            attributes: [NSAttributedString.Key.foregroundColor: ColorPalette.gtBlue.uiColor]
        )
        
        let attributedString = NSAttributedString(format: NSAttributedString(string: formatString), args: languageNameAttributed)
        
        return attributedString
    }
}
