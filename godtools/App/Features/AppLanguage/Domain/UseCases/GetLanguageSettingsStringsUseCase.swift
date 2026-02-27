//
//  GetLanguageSettingsStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetLanguageSettingsStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    private let appLanguagesRepository: AppLanguagesRepository
    
    init(localizationServices: LocalizationServicesInterface, getTranslatedLanguageName: GetTranslatedLanguageName, appLanguagesRepository: AppLanguagesRepository) {
        
        self.localizationServices = localizationServices
        self.getTranslatedLanguageName = getTranslatedLanguageName
        self.appLanguagesRepository = appLanguagesRepository
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<LanguageSettingsStringsDomainModel, Error> {
        
        let localeId: String = appLanguage
        
        return getNumberOfAppLanguagesAvailableStringPublisher(translateInAppLanguage: appLanguage)
            .map { (numberOfAppLanguagesInterfaceString: String) in
                
                let interfaceStrings = LanguageSettingsStringsDomainModel(
                    navTitle: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsNavTitle.key),
                    appInterfaceLanguageTitle: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsAppInterfaceTitle.key),
                    numberOfAppLanguagesAvailable: numberOfAppLanguagesInterfaceString,
                    setAppLanguageMessage: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsAppInterfaceMessage.key),
                    chooseAppLanguageButtonTitle: self.getTranslatedLanguageName.getLanguageName(language: appLanguage, translatedInLanguage: appLanguage),
                    toolLanguagesAvailableOfflineTitle: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineTitle.key),
                    downloadToolsForOfflineMessage: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineMessage.key),
                    editDownloadedLanguagesButtonTitle: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineEditDownloadedLanguagesButtonTitle.key)
                )
                
                return interfaceStrings
            }
            .eraseToAnyPublisher()
    }
    
    @MainActor private func getNumberOfAppLanguagesAvailableStringPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<String, Error> {
        
        return appLanguagesRepository
            .observeNumberOfAppLanguagesPublisher()
            .map { (numberOfAppLanguages: Int) in
                
                let localizedNumberOfLanguagesAvailable = self.localizationServices.stringForLocaleElseSystemElseEnglish(
                    localeIdentifier: translateInAppLanguage,
                    key: LocalizableStringDictKeys.languageSettingsAppLanguageNumberAvailable.key
                )
                
                let stringLocaleFormat = String(
                    format: localizedNumberOfLanguagesAvailable,
                    locale: Locale(identifier: translateInAppLanguage),
                    numberOfAppLanguages
                )
                                    
                return stringLocaleFormat
            }
            .eraseToAnyPublisher()
    }
}

