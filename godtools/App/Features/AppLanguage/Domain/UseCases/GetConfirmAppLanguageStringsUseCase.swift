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
        
        let strings = ConfirmAppLanguageStringsDomainModel(
            messageInNewlySelectedLanguageHighlightModel: await getHighlightMessageStringDomainModel(selectedLanguage: selectedLanguage, localeId: selectedLanguage),
            messageInCurrentLanguageHighlightModel: await getHighlightMessageStringDomainModel(selectedLanguage: selectedLanguage, localeId: appLanguageLocaleId),
            changeLanguageButtonText: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageLocaleId, key: LocalizableStringKeys.languageSettingsConfirmAppLanguageChangeLanguageButtonTitle.key),
            nevermindButtonText: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageLocaleId, key: LocalizableStringKeys.languageSettingsConfirmAppLanguageNevermindButtonTitle.key)
        )
        
        return strings
    }
    
    private func getHighlightMessageStringDomainModel(selectedLanguage: AppLanguageDomainModel, localeId: String) async -> ConfirmAppLanguageHighlightStringDomainModel {
        
        let formatString = await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsConfirmAppLanguageMessage.key)
        let languageName = await getTranslatedLanguageName.getLanguageName(language: selectedLanguage, translatedInLanguage: localeId)
        
        let fullText = String(format: formatString, languageName)
        
        return ConfirmAppLanguageHighlightStringDomainModel(fullText: fullText, highlightText: languageName)
    }
}
