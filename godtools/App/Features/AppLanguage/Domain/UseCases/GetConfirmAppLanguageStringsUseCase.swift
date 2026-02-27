//
//  GetConfirmAppLanguageStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 10/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetConfirmAppLanguageStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    
    init(localizationServices: LocalizationServicesInterface, getTranslatedLanguageName: GetTranslatedLanguageName) {
        
        self.localizationServices = localizationServices
        self.getTranslatedLanguageName = getTranslatedLanguageName
    }
    
    func execute(appLanguage: AppLanguageDomainModel, selectedLanguage: AppLanguageDomainModel) -> AnyPublisher<ConfirmAppLanguageStringsDomainModel, Never> {
        
        let appLanguageLocaleId: String = appLanguage
        
        let strings = ConfirmAppLanguageStringsDomainModel(
            messageInNewlySelectedLanguageHighlightModel: getHighlightMessageStringDomainModel(selectedLanguage: selectedLanguage, localeId: selectedLanguage),
            messageInCurrentLanguageHighlightModel: getHighlightMessageStringDomainModel(selectedLanguage: selectedLanguage, localeId: appLanguageLocaleId),
            changeLanguageButtonText: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageLocaleId, key: "languageSettings.confirmAppLanguage.changeLanguageButton.title"),
            nevermindButtonText: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageLocaleId, key: "languageSettings.confirmAppLanguage.nevermindButton.title")
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
    
    private func getHighlightMessageStringDomainModel(selectedLanguage: AppLanguageDomainModel, localeId: String) -> ConfirmAppLanguageHighlightStringDomainModel {
        
        let formatString = localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "languageSettings.confirmAppLanguage.message")
        let languageName = getTranslatedLanguageName.getLanguageName(language: selectedLanguage, translatedInLanguage: localeId)
        
        let fullText = String(format: formatString, languageName)
        
        return ConfirmAppLanguageHighlightStringDomainModel(fullText: fullText, highlightText: languageName)
    }
}
