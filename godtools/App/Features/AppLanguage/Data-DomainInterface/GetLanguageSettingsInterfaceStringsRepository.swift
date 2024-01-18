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
    
    private let localizationServices: LocalizationServices
    private let localeLanguageName: LocaleLanguageName
    private let appLanguagesRepository: AppLanguagesRepository
    
    init(localizationServices: LocalizationServices, localeLanguageName: LocaleLanguageName, appLanguagesRepository: AppLanguagesRepository) {
        
        self.localizationServices = localizationServices
        self.localeLanguageName = localeLanguageName
        self.appLanguagesRepository = appLanguagesRepository
    }
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<LanguageSettingsInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInAppLanguage
        
        let interfaceStrings = LanguageSettingsInterfaceStringsDomainModel(
            navTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: AppLanguageStringKeys.LanguageSettings.navTitle.rawValue),
            appInterfaceLanguageTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "languageSettings.appInterface.title"),
            numberOfAppLanguagesAvailable: getNumberOfAppLanguagesAvailableString(translateInAppLanguage: translateInAppLanguage),
            setAppLanguageMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "languageSettings.appInterface.message"),
            chooseAppLanguageButtonTitle: localeLanguageName.getLanguageName(forLanguageCode: translateInAppLanguage, translatedInLanguageId: translateInAppLanguage) ?? "",
            toolLanguagesAvailableOfflineTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "languageSettings.toolLanguagesAvailableOffline.title"),
            downloadToolsForOfflineMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "languageSettings.toolLanguagesAvailableOffline.message"),
            editDownloadedLanguagesButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "languageSettings.toolLanguagesAvailableOffline.editDownloadedLanguagesButton.title")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
    
    private func getNumberOfAppLanguagesAvailableString(translateInAppLanguage: AppLanguageDomainModel) -> String {
        
        let numberOfAppLanguages: Int = appLanguagesRepository.getNumberOfCachedLanguages()
        
        let localizedNumberOfLanguagesAvailable = localizationServices.stringForLocaleElseSystemElseEnglish(
            localeIdentifier: translateInAppLanguage,
            key: "languageSettings.appLanguage.numberAvailable",
            fileType: .stringsdict
        )
        
        let stringLocaleFormat = String(format: localizedNumberOfLanguagesAvailable, locale: Locale(identifier: translateInAppLanguage), numberOfAppLanguages)
                            
        return stringLocaleFormat
    }
}
