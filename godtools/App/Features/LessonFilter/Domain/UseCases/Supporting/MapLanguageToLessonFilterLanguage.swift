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
    ) -> ToolLanguageFilterItemDomainModel {
        
        let lessonsAvailableCount: Int = resourcesRepository.getLessonsCount(filterByLanguageId: language.id)

        let languageNameTranslatedInLanguage = getTranslatedLanguageName.getLanguageName(
            language: language.code,
            translatedInLanguage: language.code
        )
        
        let languageNameTranslatedInAppLanguage = getTranslatedLanguageName.getLanguageName(
            language: language.code,
            translatedInLanguage: translatedInAppLanguage
        )
        
        let lessonsAvailableText: String = getLessonsAvailableText(
            lessonsAvailableCount: lessonsAvailableCount,
            translatedInAppLanguage: translatedInAppLanguage
        )
        
        return ToolLanguageFilterItemDomainModel(
            languageId: language.id,
            languageNameTranslatedInLanguage: languageNameTranslatedInLanguage,
            languageNameTranslatedInAppLanguage: languageNameTranslatedInAppLanguage,
            availableText: lessonsAvailableText,
            availableCount: lessonsAvailableCount
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
