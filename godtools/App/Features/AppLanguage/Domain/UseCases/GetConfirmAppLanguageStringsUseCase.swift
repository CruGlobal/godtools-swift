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
    
    func execute(appLanguage: AppLanguageDomainModel, selectedLanguage: AppLanguageDomainModel) async -> ConfirmAppLanguageStringsDomainModel {
        
        let appLanguageLocaleId: String = appLanguage

        let changeLanguageButtonTextKey: String = LocalizableStringKeys.languageSettingsConfirmAppLanguageChangeLanguageButtonTitle.key
        let nevermindButtonTextKey: String = LocalizableStringKeys.languageSettingsConfirmAppLanguageNevermindButtonTitle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                changeLanguageButtonTextKey,
                nevermindButtonTextKey
            ],
            fetchOrder: [
                .locale(identifier: appLanguageLocaleId),
                .english
            ],
            shouldFallbackToKey: true
        )

        return ConfirmAppLanguageStringsDomainModel(
            messageInNewlySelectedLanguageHighlightModel: await getHighlightMessageStringDomainModel(selectedLanguage: selectedLanguage, localeId: selectedLanguage),
            messageInCurrentLanguageHighlightModel: await getHighlightMessageStringDomainModel(selectedLanguage: selectedLanguage, localeId: appLanguageLocaleId),
            changeLanguageButtonText: strings[changeLanguageButtonTextKey] ?? "",
            nevermindButtonText: strings[nevermindButtonTextKey] ?? ""
        )
    }

    private func getHighlightMessageStringDomainModel(selectedLanguage: AppLanguageDomainModel, localeId: String) async -> ConfirmAppLanguageHighlightStringDomainModel {

        let messageKey: String = LocalizableStringKeys.languageSettingsConfirmAppLanguageMessage.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                messageKey
            ],
            fetchOrder: [
                .locale(identifier: localeId),
                .english
            ],
            shouldFallbackToKey: true
        )

        let formatString: String = strings[messageKey] ?? ""
        let languageName = await getTranslatedLanguageName.getLanguageName(language: selectedLanguage, translatedInLanguage: localeId)
        
        let fullText = String(format: formatString, languageName)
        
        return ConfirmAppLanguageHighlightStringDomainModel(fullText: fullText, highlightText: languageName)
    }
}
