//
//  GetLanguageSettingsStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetLanguageSettingsStringsUseCase: Sendable {
    
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
    
    func execute(appLanguage: AppLanguageDomainModel) async -> LanguageSettingsStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let numberOfAppLanguages: Int = appLanguagesRepository.numberOfAppLanguages
        
        let localizedNumberOfLanguagesAvailable = await localizationServices.stringForLocaleElseSystemElseEnglish(
            localeIdentifier: appLanguage,
            key: LocalizableStringDictKeys.languageSettingsAppLanguageNumberAvailable.key
        )
        
        let numberOfAppLanguagesInterfaceString = String(
            format: localizedNumberOfLanguagesAvailable,
            locale: Locale(identifier: appLanguage),
            numberOfAppLanguages
        )
        
        return LanguageSettingsStringsDomainModel(
            navTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsNavTitle.key),
            appInterfaceLanguageTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsAppInterfaceTitle.key),
            numberOfAppLanguagesAvailable: numberOfAppLanguagesInterfaceString,
            setAppLanguageMessage: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsAppInterfaceMessage.key),
            chooseAppLanguageButtonTitle: await getTranslatedLanguageName.getLanguageName(language: appLanguage, translatedInLanguage: appLanguage),
            toolLanguagesAvailableOfflineTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineTitle.key),
            downloadToolsForOfflineMessage: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineMessage.key),
            editDownloadedLanguagesButtonTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineEditDownloadedLanguagesButtonTitle.key)
        )
    }
}

