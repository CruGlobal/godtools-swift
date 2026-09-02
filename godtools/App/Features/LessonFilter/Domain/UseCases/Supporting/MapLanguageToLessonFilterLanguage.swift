//
//  MapLanguageToLessonFilterLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class MapLanguageToLessonFilterLanguage: Sendable {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    private let localizationServices: LocalizationServicesInterface
    private let stringWithLocaleCount: StringWithLocaleCountInterface
    
    init(
        resourcesRepository: ResourcesRepository,
        languagesRepository: LanguagesRepository,
        getTranslatedLanguageName: GetTranslatedLanguageName,
        localizationServices: LocalizationServicesInterface,
        stringWithLocaleCount: StringWithLocaleCountInterface
    ) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedLanguageName = getTranslatedLanguageName
        self.localizationServices = localizationServices
        self.stringWithLocaleCount = stringWithLocaleCount
    }
    
    func map(
        language: LanguageDataModel,
        translatedInAppLanguage: AppLanguageDomainModel
    ) -> LessonFilterLanguageDomainModel {
        
        let lessonsAvailableCount: Int = resourcesRepository.getLessonsCount(filterByLanguageId: language.id)

        let languageNamePair: TranslatedLanguageNamePairDomainModel = getTranslatedLanguageName.getLanguageNamePair(
            language: language,
            appLanguage: translatedInAppLanguage
        )
        
        let lessonsAvailableText: String = getLessonsAvailableText(
            lessonsAvailableCount: lessonsAvailableCount,
            translatedInAppLanguage: translatedInAppLanguage
        )
        
        return LessonFilterLanguageDomainModel(
            languageId: language.id,
            languageNamePair: languageNamePair,
            lessonsAvailableText: lessonsAvailableText,
            lessonsAvailableCount: lessonsAvailableCount
        )
    }
    
    private func getLessonsAvailableText(
        lessonsAvailableCount: Int,
        translatedInAppLanguage: AppLanguageDomainModel
    ) -> String {
        
        let formatStringKey: String = LocalizableStringKeys.lessonsFilterLessonsAvailable.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                formatStringKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: translatedInAppLanguage.localeId),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        let formatString: String = strings[formatStringKey] ?? ""
        
        return stringWithLocaleCount.getString(
            format: formatString,
            locale: Locale(identifier: translatedInAppLanguage),
            count: lessonsAvailableCount
        )
    }
}
