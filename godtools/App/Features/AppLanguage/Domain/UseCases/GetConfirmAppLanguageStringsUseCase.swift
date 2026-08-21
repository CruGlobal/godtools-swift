//
//  GetConfirmAppLanguageStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 10/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetConfirmAppLanguageStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    
    init(localizationServices: LocalizationServicesInterface, getTranslatedLanguageName: GetTranslatedLanguageName) {
        
        self.localizationServices = localizationServices
        self.getTranslatedLanguageName = getTranslatedLanguageName
    }
    
    func execute(appLanguage: AppLanguageDomainModel, selectedLanguage: AppLanguageDomainModel) -> ConfirmAppLanguageStringsDomainModel {
        
        let appLanguageLocaleId: String = appLanguage

        let changeLanguageButtonTextKey: String = LocalizableStringKeys.languageSettingsConfirmAppLanguageChangeLanguageButtonTitle.key
        let nevermindButtonTextKey: String = LocalizableStringKeys.languageSettingsConfirmAppLanguageNevermindButtonTitle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                changeLanguageButtonTextKey,
                nevermindButtonTextKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguageLocaleId),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return ConfirmAppLanguageStringsDomainModel(
            messageInNewlySelectedLanguageHighlightModel: getHighlightMessageStringDomainModel(selectedLanguage: selectedLanguage, localeId: selectedLanguage),
            messageInCurrentLanguageHighlightModel: getHighlightMessageStringDomainModel(selectedLanguage: selectedLanguage, localeId: appLanguageLocaleId),
            changeLanguageButtonText: strings[changeLanguageButtonTextKey] ?? "",
            nevermindButtonText: strings[nevermindButtonTextKey] ?? ""
        )
    }

    private func getHighlightMessageStringDomainModel(selectedLanguage: AppLanguageDomainModel, localeId: String) -> ConfirmAppLanguageHighlightStringDomainModel {

        let messageKey: String = LocalizableStringKeys.languageSettingsConfirmAppLanguageMessage.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                messageKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: localeId),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        let formatString: String = strings[messageKey] ?? ""
        let languageName = getTranslatedLanguageName.getLanguageName(language: selectedLanguage, translatedInLanguage: localeId)
        
        let fullText = String(format: formatString, languageName)
        
        return ConfirmAppLanguageHighlightStringDomainModel(fullText: fullText, highlightText: languageName)
    }
}
