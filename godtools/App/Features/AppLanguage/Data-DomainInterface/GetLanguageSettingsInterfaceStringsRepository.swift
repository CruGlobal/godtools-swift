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
    
    init(localizationServices: LocalizationServices, localeLanguageName: LocaleLanguageName) {
        
        self.localizationServices = localizationServices
        self.localeLanguageName = localeLanguageName
    }
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<LanguageSettingsInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInAppLanguage
        
        let interfaceStrings = LanguageSettingsInterfaceStringsDomainModel(
            navTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: AppLanguageStringKeys.LanguageSettings.navTitle.rawValue),
            appInterfaceLanguageTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "languageSettings.appInterface.title"),
            setAppLanguageMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "languageSettings.appInterface.message"),
            chooseAppLanguageButtonTitle: localeLanguageName.getLanguageName(forLanguageId: translateInAppLanguage, translatedInLanguageId: translateInAppLanguage) ?? "",
            toolLanguagesAvailableOfflineTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "languageSettings.toolLanguagesAvailableOffline.title"),
            downloadToolsForOfflineMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "languageSettings.toolLanguagesAvailableOffline.message"),
            editDownloadedLanguagesButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "languageSettings.toolLanguagesAvailableOffline.editDownloadedLanguagesButton.title")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
