//
//  GetLessonFilterLanguagesRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 7/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine
import LocalizationServices

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
    
    func getLessonFilterLanguagesPublisher(translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<[LessonFilterLanguageDomainModel], Never> {
        
        return resourcesRepository
            .getResourcesChangedPublisher()
            .flatMap { _ in
                
                let languageIds = self.resourcesRepository.getAllLessonLanguageIds()
                
                let languages = self.createLessonLanguageFilterDomainModelList(from: languageIds, translatedInAppLanguage: translatedInAppLanguage)
                
                return Just(languages)
            }
            .eraseToAnyPublisher()
    }
    
    func getLessonLanguageFilterFromLanguageCode(languageCode: String?, translatedInAppLanguage: AppLanguageDomainModel) -> LessonFilterLanguageDomainModel? {
        
        guard let languageCode = languageCode,
              let language = languagesRepository.getCachedLanguage(code: languageCode)
        else {
            return nil
        }
        
        return createLessonLanguageFilterDomainModel(with: language, translatedInAppLanguage: translatedInAppLanguage)
    }
    
    func getLessonLanguageFilterFromLanguageId(languageId: String?, translatedInAppLanguage: AppLanguageDomainModel) -> LessonFilterLanguageDomainModel? {
        
        guard let languageId = languageId,
              let language = languagesRepository.getCachedObject(id: languageId)
        else {
            return nil
        }
        
        return createLessonLanguageFilterDomainModel(with: language, translatedInAppLanguage: translatedInAppLanguage)
    }
}

extension GetLessonFilterLanguagesRepository {
    
    private func createLessonLanguageFilterDomainModelList(from languageIds: [String], translatedInAppLanguage: AppLanguageDomainModel) -> [LessonFilterLanguageDomainModel] {
        
        let languages: [LessonFilterLanguageDomainModel] = languagesRepository.getCachedObjects(ids: languageIds)
            .compactMap { (languageModel: LanguageDataModel) in
                
                let lessonsAvailableCount: Int = resourcesRepository.getAllLessonsCount(filterByLanguageId: languageModel.id)
                
                guard lessonsAvailableCount > 0 else {
                    return nil
                }
                
                return self.createLessonLanguageFilterDomainModel(
                    with: languageModel,
                    translatedInAppLanguage: translatedInAppLanguage
                )
            }
            .sorted { (language1: LessonFilterLanguageDomainModel, language2: LessonFilterLanguageDomainModel) in
                
                return language1.languageNameTranslatedInAppLanguage.lowercased() < language2.languageNameTranslatedInAppLanguage.lowercased()
            }
        
        return languages
    }
    
    private func createLessonLanguageFilterDomainModel(with languageModel: LanguageDataModel, translatedInAppLanguage: AppLanguageDomainModel) -> LessonFilterLanguageDomainModel? {
        
        let lessonsAvailableCount: Int = resourcesRepository.getAllLessonsCount(filterByLanguageId: languageModel.id)

        let languageNameTranslatedInLanguage = getTranslatedLanguageName.getLanguageName(language: languageModel.code, translatedInLanguage: languageModel.code)
        let languageNameTranslatedInAppLanguage = getTranslatedLanguageName.getLanguageName(language: languageModel.code, translatedInLanguage: translatedInAppLanguage)
        
        let lessonsAvailableText: String = getLessonsAvailableText(lessonsAvailableCount: lessonsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return LessonFilterLanguageDomainModel(
            languageId: languageModel.id,
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
