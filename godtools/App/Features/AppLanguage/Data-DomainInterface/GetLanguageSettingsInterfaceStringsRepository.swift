//
//  GetLanguageSettingsInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLanguageSettingsInterfaceStringsRepository: GetLanguageSettingsInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServicesInterface
    private let translatedLanguageNameRepository: TranslatedLanguageNameRepository
    private let appLanguagesRepository: AppLanguagesRepository
    
    init(localizationServices: LocalizationServicesInterface, translatedLanguageNameRepository: TranslatedLanguageNameRepository, appLanguagesRepository: AppLanguagesRepository) {
        
        self.localizationServices = localizationServices
        self.translatedLanguageNameRepository = translatedLanguageNameRepository
        self.appLanguagesRepository = appLanguagesRepository
    }
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<LanguageSettingsInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInAppLanguage
        
        let interfaceStrings = LanguageSettingsInterfaceStringsDomainModel(
            navTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsNavTitle.key, fileType: .strings),
            appInterfaceLanguageTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsAppInterfaceTitle.key, fileType: .strings),
            numberOfAppLanguagesAvailable: getNumberOfAppLanguagesAvailableString(translateInAppLanguage: translateInAppLanguage),
            setAppLanguageMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsAppInterfaceMessage.key, fileType: .strings),
            chooseAppLanguageButtonTitle: translatedLanguageNameRepository.getLanguageName(language: translateInAppLanguage, translatedInLanguage: translateInAppLanguage),
            toolLanguagesAvailableOfflineTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineTitle.key, fileType: .strings),
            downloadToolsForOfflineMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineMessage.key, fileType: .strings),
            editDownloadedLanguagesButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineEditDownloadedLanguagesButtonTitle.key, fileType: .strings)
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
    
    private func getNumberOfAppLanguagesAvailableString(translateInAppLanguage: AppLanguageDomainModel) -> String {
        
        let numberOfAppLanguages: Int = appLanguagesRepository.getNumberOfCachedLanguages()
        
        let localizedNumberOfLanguagesAvailable = localizationServices.stringForLocaleElseSystemElseEnglish(
            localeIdentifier: translateInAppLanguage,
            key: LocalizableStringDictKeys.languageSettingsAppLanguageNumberAvailable.key,
            fileType: .stringsdict
        )
        
        let stringLocaleFormat = String(format: localizedNumberOfLanguagesAvailable, locale: Locale(identifier: translateInAppLanguage), numberOfAppLanguages)
                            
        return stringLocaleFormat
    }
}
