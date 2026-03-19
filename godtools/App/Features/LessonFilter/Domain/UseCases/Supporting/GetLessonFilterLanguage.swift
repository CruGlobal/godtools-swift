//
//  GetLessonFilterLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetLessonFilterLanguage {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    private let localizationServices: LocalizationServicesInterface
    private let stringWithLocaleCount: StringWithLocaleCountInterface
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, getTranslatedLanguageName: GetTranslatedLanguageName, localizationServices: LocalizationServicesInterface, stringWithLocaleCount: StringWithLocaleCountInterface) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedLanguageName = getTranslatedLanguageName
        self.localizationServices = localizationServices
        self.stringWithLocaleCount = stringWithLocaleCount
    }
    
    func getLessonLanguageFilterFromLanguageCode(languageCode: String, translatedInAppLanguage: AppLanguageDomainModel) -> LessonFilterLanguageDomainModel? {
        
        guard let language = languagesRepository.cache.getCachedLanguage(code: languageCode) else {
            return nil
        }
        
        return mapLanguageToLessonFilterLanguageDomainModel(language: language, translatedInAppLanguage: translatedInAppLanguage)
    }
    
    func getLessonLanguageFilterFromLanguageId(languageId: String, translatedInAppLanguage: AppLanguageDomainModel) -> LessonFilterLanguageDomainModel? {
        
        guard let language = languagesRepository.persistence.getDataModelNonThrowing(id: languageId) else {
            return nil
        }
        
        return mapLanguageToLessonFilterLanguageDomainModel(language: language, translatedInAppLanguage: translatedInAppLanguage)
    }
    
    func mapLanguageToLessonFilterLanguageDomainModel(language: LanguageDataModel, translatedInAppLanguage: AppLanguageDomainModel) -> LessonFilterLanguageDomainModel {
        
        let lessonsAvailableCount: Int = resourcesRepository.cache.getLessonsCount(filterByLanguageId: language.id)

        let languageNameTranslatedInLanguage = getTranslatedLanguageName.getLanguageName(language: language.code, translatedInLanguage: language.code)
        let languageNameTranslatedInAppLanguage = getTranslatedLanguageName.getLanguageName(language: language.code, translatedInLanguage: translatedInAppLanguage)
        
        let lessonsAvailableText: String = getLessonsAvailableText(lessonsAvailableCount: lessonsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return LessonFilterLanguageDomainModel(
            languageId: language.id,
            languageNameTranslatedInLanguage: languageNameTranslatedInLanguage,
            languageNameTranslatedInAppLanguage: languageNameTranslatedInAppLanguage,
            lessonsAvailableText: lessonsAvailableText,
            lessonsAvailableCount: lessonsAvailableCount
        )
    }
    
    private func getLessonsAvailableText(lessonsAvailableCount: Int, translatedInAppLanguage: AppLanguageDomainModel) -> String {
        
        let formatString = localizationServices.stringForLocaleElseSystemElseEnglish(
            localeIdentifier: translatedInAppLanguage.localeId,
            key: LessonFilterStringKeys.lessonsAvailableText.rawValue
        )
        
        return stringWithLocaleCount.getString(format: formatString, locale: Locale(identifier: translatedInAppLanguage), count: lessonsAvailableCount)
    }
}
