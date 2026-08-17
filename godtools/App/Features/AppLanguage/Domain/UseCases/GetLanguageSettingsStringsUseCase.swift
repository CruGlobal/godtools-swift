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

        let numberOfAppLanguagesAvailableKey: String = LocalizableStringDictKeys.languageSettingsAppLanguageNumberAvailable.key

        let numberOfAppLanguagesAvailableStrings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                numberOfAppLanguagesAvailableKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: localeId),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        let localizedNumberOfLanguagesAvailable: String = numberOfAppLanguagesAvailableStrings[numberOfAppLanguagesAvailableKey] ?? ""

        let numberOfAppLanguagesInterfaceString = String(
            format: localizedNumberOfLanguagesAvailable,
            locale: Locale(identifier: appLanguage),
            numberOfAppLanguages
        )

        let navTitleKey: String = LocalizableStringKeys.languageSettingsNavTitle.key
        let appInterfaceLanguageTitleKey: String = LocalizableStringKeys.languageSettingsAppInterfaceTitle.key
        let setAppLanguageMessageKey: String = LocalizableStringKeys.languageSettingsAppInterfaceMessage.key
        let toolLanguagesAvailableOfflineTitleKey: String = LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineTitle.key
        let downloadToolsForOfflineMessageKey: String = LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineMessage.key
        let editDownloadedLanguagesButtonTitleKey: String = LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineEditDownloadedLanguagesButtonTitle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                navTitleKey,
                appInterfaceLanguageTitleKey,
                setAppLanguageMessageKey,
                toolLanguagesAvailableOfflineTitleKey,
                downloadToolsForOfflineMessageKey,
                editDownloadedLanguagesButtonTitleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: localeId),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return LanguageSettingsStringsDomainModel(
            navTitle: strings[navTitleKey] ?? "",
            appInterfaceLanguageTitle: strings[appInterfaceLanguageTitleKey] ?? "",
            numberOfAppLanguagesAvailable: numberOfAppLanguagesInterfaceString,
            setAppLanguageMessage: strings[setAppLanguageMessageKey] ?? "",
            chooseAppLanguageButtonTitle: await getTranslatedLanguageName.getLanguageName(language: appLanguage, translatedInLanguage: appLanguage),
            toolLanguagesAvailableOfflineTitle: strings[toolLanguagesAvailableOfflineTitleKey] ?? "",
            downloadToolsForOfflineMessage: strings[downloadToolsForOfflineMessageKey] ?? "",
            editDownloadedLanguagesButtonTitle: strings[editDownloadedLanguagesButtonTitleKey] ?? ""
        )
    }
}

