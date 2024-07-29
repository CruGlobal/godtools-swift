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
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, getTranslatedLanguageName: GetTranslatedLanguageName, localizationServices: LocalizationServicesInterface) {
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedLanguageName = getTranslatedLanguageName
        self.localizationServices = localizationServices
    }
    
    func getLessonFilterLanguagesPublisher(translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<[LessonFilterLanguageDomainModel], Never> {
        
        return resourcesRepository.getResourcesChangedPublisher()
            .flatMap { _ in
                
                let languageIds = self.resourcesRepository.getAllLessonLanguageIds()
                
                let languages = self.createLessonLanguageFilterDomainModelList(from: languageIds, translatedInAppLanguage: translatedInAppLanguage)
                
                return Just(languages)
            }
            .eraseToAnyPublisher()
    }
    
    func getLessonLanguageFilterFromLanguageCode(languageCode: String?, translatedInAppLanguage: AppLanguageDomainModel) -> LessonFilterLanguageDomainModel? {
        
        guard let languageCode = languageCode,
              let language = languagesRepository.getLanguage(code: languageCode)
        else {
            return nil
        }
        
        return createLessonLanguageFilterDomainModel(with: language, translatedInAppLanguage: translatedInAppLanguage)
    }
    
    func getLessonLanguageFilterFromLanguageId(languageId: String?, translatedInAppLanguage: AppLanguageDomainModel) -> LessonFilterLanguageDomainModel? {
        
        guard let languageId = languageId,
              let language = languagesRepository.getLanguage(id: languageId)
        else {
            return nil
        }
        
        return createLessonLanguageFilterDomainModel(with: language, translatedInAppLanguage: translatedInAppLanguage)
    }
}

extension GetLessonFilterLanguagesRepository {
    
    private func createLessonLanguageFilterDomainModelList(from languageIds: [String], translatedInAppLanguage: AppLanguageDomainModel) -> [LessonFilterLanguageDomainModel] {
        
        let languages: [LessonFilterLanguageDomainModel] = languagesRepository.getLanguages(ids: languageIds)
            .compactMap { languageModel in
                
                let lessonsAvailableCount: Int = resourcesRepository.getAllLessonsCount(filterByLanguageId: languageModel.id)
                
                guard lessonsAvailableCount > 0 else {
                    return nil
                }
                
                return self.createLessonLanguageFilterDomainModel(with: languageModel, translatedInAppLanguage: translatedInAppLanguage)
            }
            .sorted { language1, language2 in
                
                return language1.translatedName.lowercased() < language2.translatedName.lowercased()
            }
        
        return languages
    }
    
    private func createLessonLanguageFilterDomainModel(with languageModel: LanguageModel, translatedInAppLanguage: AppLanguageDomainModel) -> LessonFilterLanguageDomainModel? {
        
        let lessonsAvailableCount: Int = resourcesRepository.getAllLessonsCount(filterByLanguageId: languageModel.id)

        let languageName = getTranslatedLanguageName.getLanguageName(language: languageModel.code, translatedInLanguage: languageModel.code)
        let translatedLanguageName = getTranslatedLanguageName.getLanguageName(language: languageModel.code, translatedInLanguage: translatedInAppLanguage)
        
        let lessonsAvailableText: String = getLessonsAvailableText(lessonsAvailableCount: lessonsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return LessonFilterLanguageDomainModel(
            languageId: languageModel.id,
            languageName: languageName,
            translatedName: translatedLanguageName,
            lessonsAvailableText: lessonsAvailableText
        )
    }
    
    func getLessonsAvailableText(lessonsAvailableCount: Int, translatedInAppLanguage: AppLanguageDomainModel) -> String {
        
        let formatString = localizationServices.stringForLocaleElseSystemElseEnglish(
            localeIdentifier: translatedInAppLanguage.localeId,
            key: LessonFilterStringKeys.lessonsAvailableText.rawValue
        )
        
        let localizedString = String(format: formatString, locale: Locale(identifier: translatedInAppLanguage), lessonsAvailableCount)
        
        return localizedString
    }
}
