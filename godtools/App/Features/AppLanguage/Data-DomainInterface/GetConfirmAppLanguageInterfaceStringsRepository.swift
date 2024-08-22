//
//  GetConfirmAppLanguageInterfaceStringsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 1/27/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine
import LocalizationServices

class GetConfirmAppLanguageInterfaceStringsRepository: GetConfirmAppLanguageInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    
    init(localizationServices: LocalizationServices, getTranslatedLanguageName: GetTranslatedLanguageName) {
        
        self.localizationServices = localizationServices
        self.getTranslatedLanguageName = getTranslatedLanguageName
    }
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel, selectedLanguage: AppLanguageDomainModel) -> AnyPublisher<ConfirmAppLanguageInterfaceStringsDomainModel, Never> {
        
        let appLanguageLocaleId: String = translateInAppLanguage
        
        let interfaceStrings = ConfirmAppLanguageInterfaceStringsDomainModel(
            messageInNewlySelectedLanguageHighlightModel: getHighlightMessageStringDomainModel(selectedLanguage: selectedLanguage, localeId: selectedLanguage),
            messageInCurrentLanguageHighlightModel: getHighlightMessageStringDomainModel(selectedLanguage: selectedLanguage, localeId: appLanguageLocaleId),
            changeLanguageButtonText: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageLocaleId, key: "languageSettings.confirmAppLanguage.changeLanguageButton.title"),
            nevermindButtonText: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageLocaleId, key: "languageSettings.confirmAppLanguage.nevermindButton.title")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
    
    private func getHighlightMessageStringDomainModel(selectedLanguage: AppLanguageDomainModel, localeId: String) -> ConfirmAppLanguageHighlightStringDomainModel {
        
        let formatString = localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "languageSettings.confirmAppLanguage.message")
        let languageName = getTranslatedLanguageName.getLanguageName(language: selectedLanguage, translatedInLanguage: localeId)
        
        return ConfirmAppLanguageHighlightStringDomainModel(highlightText: languageName, formatString: formatString)
    }
}
