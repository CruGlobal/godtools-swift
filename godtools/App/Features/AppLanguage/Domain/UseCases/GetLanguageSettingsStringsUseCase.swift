//
//  GetLanguageSettingsStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetLanguageSettingsStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    private let appLanguagesRepository: AppLanguagesRepository
    
    init(
        localizationServices: LocalizationServicesInterface,
        getTranslatedLanguageName: GetTranslatedLanguageName,
        appLanguagesRepository: AppLanguagesRepository
    ) {
        
        self.localizationServices = localizationServices
        self.getTranslatedLanguageName = getTranslatedLanguageName
        self.appLanguagesRepository = appLanguagesRepository
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> LanguageSettingsStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let numberOfAppLanguages: Int = appLanguagesRepository.numberOfAppLanguages
        
        let localizedNumberOfLanguagesAvailable = localizationServices.stringForLocaleElseSystemElseEnglish(
            localeIdentifier: appLanguage,
            key: LocalizableStringDictKeys.languageSettingsAppLanguageNumberAvailable.key
        )
        
        let numberOfAppLanguagesInterfaceString = String(
            format: localizedNumberOfLanguagesAvailable,
            locale: Locale(identifier: appLanguage),
            numberOfAppLanguages
        )
        
        return LanguageSettingsStringsDomainModel(
            navTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsNavTitle.key),
            appInterfaceLanguageTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsAppInterfaceTitle.key),
            numberOfAppLanguagesAvailable: numberOfAppLanguagesInterfaceString,
            setAppLanguageMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsAppInterfaceMessage.key),
            chooseAppLanguageButtonTitle: getTranslatedLanguageName.getLanguageName(language: appLanguage, translatedInLanguage: appLanguage),
            toolLanguagesAvailableOfflineTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineTitle.key),
            downloadToolsForOfflineMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineMessage.key),
            editDownloadedLanguagesButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineEditDownloadedLanguagesButtonTitle.key)
        )
    }
}

