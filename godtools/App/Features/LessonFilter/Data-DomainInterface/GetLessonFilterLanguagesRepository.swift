//
//  GetLessonFilterLanguagesRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 7/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLessonFilterLanguagesRepository: GetLessonFilterLanguagesRepositoryInterface {
    
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
    
    @MainActor func getLessonFilterLanguagesPublisher(translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<[LessonFilterLanguageDomainModel], Error> {
        
        return resourcesRepository
            .persistence
            .observeCollectionChangesPublisher()
            .flatMap { _ in
                
                let languageIds = self.resourcesRepository.cache.getLessonsSupportedLanguageIds()
                
                return self.createLessonLanguageFilterDomainModelList(
                    from: languageIds,
                    translatedInAppLanguage: translatedInAppLanguage
                )
            }
            .eraseToAnyPublisher()
    }
    
    @MainActor func getLessonLanguageFilterFromLanguageCode(languageCode: String?, translatedInAppLanguage: AppLanguageDomainModel) throws -> LessonFilterLanguageDomainModel? {
        
        guard let languageCode = languageCode,
              let language = try languagesRepository.cache.getCachedLanguage(code: languageCode)
        else {
            return nil
        }
        
        return try createLessonLanguageFilterDomainModel(language: language, translatedInAppLanguage: translatedInAppLanguage)
    }
    
    @MainActor func getLessonLanguageFilterFromLanguageId(languageId: String?, translatedInAppLanguage: AppLanguageDomainModel) throws -> LessonFilterLanguageDomainModel? {
        
        guard let languageId = languageId,
              let language = try languagesRepository.persistence.getDataModel(id: languageId)
        else {
            return nil
        }
        
        return try createLessonLanguageFilterDomainModel(language: language, translatedInAppLanguage: translatedInAppLanguage)
    }
}

extension GetLessonFilterLanguagesRepository {
    
    @MainActor private func createLessonLanguageFilterDomainModelList(from languageIds: [String], translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<[LessonFilterLanguageDomainModel], Error> {
        
        return languagesRepository
            .persistence
            .getDataModelsPublisher(getOption: .objectsByIds(ids: languageIds))
            .tryMap { (languages: [LanguageDataModel]) in
                
                let domainModels: [LessonFilterLanguageDomainModel] = try languages.compactMap { (language: LanguageDataModel) in
                    
                    return try self.createLessonLanguageFilterDomainModel(
                        language: language,
                        translatedInAppLanguage: translatedInAppLanguage
                    )
                }
                
                return domainModels.sorted { (language1: LessonFilterLanguageDomainModel, language2: LessonFilterLanguageDomainModel) in
                    
                    return language1.languageNameTranslatedInAppLanguage.lowercased() < language2.languageNameTranslatedInAppLanguage.lowercased()
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func createLessonLanguageFilterDomainModel(language: LanguageDataModel, translatedInAppLanguage: AppLanguageDomainModel) throws -> LessonFilterLanguageDomainModel? {
        
        let lessonsAvailableCount: Int = try resourcesRepository.cache.getLessonsCount(filterByLanguageId: language.id)

        guard lessonsAvailableCount > 0 else {
            return nil
        }
        
        let languageNameTranslatedInLanguage = getTranslatedLanguageName.getLanguageName(language: language.code, translatedInLanguage: language.code)
        let languageNameTranslatedInAppLanguage = getTranslatedLanguageName.getLanguageName(language: language.code, translatedInLanguage: translatedInAppLanguage)
        
        let lessonsAvailableText: String = getLessonsAvailableText(lessonsAvailableCount: lessonsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return LessonFilterLanguageDomainModel(
            languageId: language.id,
            languageNameTranslatedInLanguage: languageNameTranslatedInLanguage,
            languageNameTranslatedInAppLanguage: languageNameTranslatedInAppLanguage,
            lessonsAvailableText: lessonsAvailableText
        )
    }
    
    func getLessonsAvailableText(lessonsAvailableCount: Int, translatedInAppLanguage: AppLanguageDomainModel) -> String {
        
        let formatString = localizationServices.stringForLocaleElseSystemElseEnglish(
            localeIdentifier: translatedInAppLanguage.localeId,
            key: LessonFilterStringKeys.lessonsAvailableText.rawValue
        )
        
        return stringWithLocaleCount.getString(format: formatString, locale: Locale(identifier: translatedInAppLanguage), count: lessonsAvailableCount)
    }
}
