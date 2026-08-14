//
//  GetLessonFilterLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetLessonFilterLanguage: Sendable {
    
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
    
    func getLessonLanguageFilterFromLanguageCode(languageCode: String, translatedInAppLanguage: AppLanguageDomainModel) async -> LessonFilterLanguageDomainModel? {
        
        guard let language = languagesRepository.getLanguageByCode(code: languageCode) else {
            return nil
        }
        
        return await mapLanguageToLessonFilterLanguageDomainModel(language: language, translatedInAppLanguage: translatedInAppLanguage)
    }
    
    func getLessonLanguageFilterFromLanguageId(languageId: String, translatedInAppLanguage: AppLanguageDomainModel) async -> LessonFilterLanguageDomainModel? {
        
        guard let language = languagesRepository.getLanguageById(id: languageId) else {
            return nil
        }
        
        return await mapLanguageToLessonFilterLanguageDomainModel(language: language, translatedInAppLanguage: translatedInAppLanguage)
    }
    
    func mapLanguageToLessonFilterLanguageDomainModel(language: LanguageDataModel, translatedInAppLanguage: AppLanguageDomainModel) async -> LessonFilterLanguageDomainModel {
        
        let lessonsAvailableCount: Int = resourcesRepository.getLessonsCount(filterByLanguageId: language.id)

        let languageNameTranslatedInLanguage = await getTranslatedLanguageName.getLanguageName(language: language.code, translatedInLanguage: language.code)
        let languageNameTranslatedInAppLanguage = await getTranslatedLanguageName.getLanguageName(language: language.code, translatedInLanguage: translatedInAppLanguage)
        
        let lessonsAvailableText: String = await getLessonsAvailableText(lessonsAvailableCount: lessonsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return LessonFilterLanguageDomainModel(
            languageId: language.id,
            languageNameTranslatedInLanguage: languageNameTranslatedInLanguage,
            languageNameTranslatedInAppLanguage: languageNameTranslatedInAppLanguage,
            lessonsAvailableText: lessonsAvailableText,
            lessonsAvailableCount: lessonsAvailableCount
        )
    }
    
    private func getLessonsAvailableText(lessonsAvailableCount: Int, translatedInAppLanguage: AppLanguageDomainModel) async -> String {
        
        let formatString = await localizationServices.stringForLocaleElseSystemElseEnglish(
            localeIdentifier: translatedInAppLanguage.localeId,
            key: LocalizableStringKeys.lessonsFilterLessonsAvailable.key
        )
        
        return stringWithLocaleCount.getString(format: formatString, locale: Locale(identifier: translatedInAppLanguage), count: lessonsAvailableCount)
    }
}
