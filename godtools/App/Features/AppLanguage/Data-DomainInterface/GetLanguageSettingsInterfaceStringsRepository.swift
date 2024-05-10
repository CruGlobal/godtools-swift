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
        
        return getNumberOfAppLanguagesAvailableStringPublisher(translateInAppLanguage: translateInAppLanguage)
            .map { (numberOfAppLanguagesInterfaceString: String) in
                
                let interfaceStrings = LanguageSettingsInterfaceStringsDomainModel(
                    navTitle: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsNavTitle.key, fileType: .strings),
                    appInterfaceLanguageTitle: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsAppInterfaceTitle.key, fileType: .strings),
                    numberOfAppLanguagesAvailable: numberOfAppLanguagesInterfaceString,
                    setAppLanguageMessage: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsAppInterfaceMessage.key, fileType: .strings),
                    chooseAppLanguageButtonTitle: self.translatedLanguageNameRepository.getLanguageName(language: translateInAppLanguage, translatedInLanguage: translateInAppLanguage),
                    toolLanguagesAvailableOfflineTitle: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineTitle.key, fileType: .strings),
                    downloadToolsForOfflineMessage: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineMessage.key, fileType: .strings),
                    editDownloadedLanguagesButtonTitle: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineEditDownloadedLanguagesButtonTitle.key, fileType: .strings)
                )
                
                return interfaceStrings
            }
            .eraseToAnyPublisher()
    }
    
    private func getNumberOfAppLanguagesAvailableStringPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<String, Never> {
        
        return appLanguagesRepository.observeNumberOfAppLanguagesPublisher()
            .map { (numberOfAppLanguages: Int) in
                
                let localizedNumberOfLanguagesAvailable = self.localizationServices.stringForLocaleElseSystemElseEnglish(
                    localeIdentifier: translateInAppLanguage,
                    key: LocalizableStringDictKeys.languageSettingsAppLanguageNumberAvailable.key,
                    fileType: .stringsdict
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
