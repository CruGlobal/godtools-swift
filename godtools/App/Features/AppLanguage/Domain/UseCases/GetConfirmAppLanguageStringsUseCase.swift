//
//  GetConfirmAppLanguageStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 10/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetConfirmAppLanguageStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    
    init(localizationServices: LocalizationServicesInterface, getTranslatedLanguageName: GetTranslatedLanguageName) {
        
        self.localizationServices = localizationServices
        self.getTranslatedLanguageName = getTranslatedLanguageName
    }
    
    func execute(appLanguage: AppLanguageDomainModel, selectedLanguage: AppLanguageDomainModel) -> ConfirmAppLanguageStringsDomainModel {
        
        let appLanguageLocaleId: String = appLanguage
        
        let strings = ConfirmAppLanguageStringsDomainModel(
            messageInNewlySelectedLanguageHighlightModel: getHighlightMessageStringDomainModel(selectedLanguage: selectedLanguage, localeId: selectedLanguage),
            messageInCurrentLanguageHighlightModel: getHighlightMessageStringDomainModel(selectedLanguage: selectedLanguage, localeId: appLanguageLocaleId),
            changeLanguageButtonText: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageLocaleId, key: LocalizableStringKeys.languageSettingsConfirmAppLanguageChangeLanguageButtonTitle.key),
            nevermindButtonText: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageLocaleId, key: LocalizableStringKeys.languageSettingsConfirmAppLanguageNevermindButtonTitle.key)
        )
        
        return strings
    }
    
    private func getHighlightMessageStringDomainModel(selectedLanguage: AppLanguageDomainModel, localeId: String) -> ConfirmAppLanguageHighlightStringDomainModel {
        
        let formatString = localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsConfirmAppLanguageMessage.key)
        let languageName = getTranslatedLanguageName.getLanguageName(language: selectedLanguage, translatedInLanguage: localeId)
        
        let fullText = String(format: formatString, languageName)
        
        return ConfirmAppLanguageHighlightStringDomainModel(fullText: fullText, highlightText: languageName)
    }
}
