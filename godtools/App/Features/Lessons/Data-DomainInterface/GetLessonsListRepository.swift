//
//  GetLessonsListRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLessonsListRepository: GetLessonsListRepositoryInterface {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let translationsRepository: TranslationsRepository
    private let localizationServices: LocalizationServices
    private let localeLanguageName: LocaleLanguageName
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, translationsRepository: TranslationsRepository, localizationServices: LocalizationServices, localeLanguageName: LocaleLanguageName) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.translationsRepository = translationsRepository
        self.localizationServices = localizationServices
        self.localeLanguageName = localeLanguageName
    }
    
    func getLessonsListPublisher(currentAppLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<[LessonListItemDomainModel], Never> {
        
        let lessons: [ResourceModel] = resourcesRepository.getAllLessons(sorted: true)
        
        let lessonListItems: [LessonListItemDomainModel] = lessons.map { (resource: ResourceModel) in
            
            let lessonIsAvailableInAppLanguage: Bool
            let lessonNameInAppLanguage: String
            
            if let translation = translationsRepository.getLatestTranslation(resourceId: resource.id, languageCode: currentAppLanguageCode) {
                lessonNameInAppLanguage = translation.translatedName
            }
            else {
                lessonNameInAppLanguage = ""
            }
            
            if let appLanguage = languagesRepository.getLanguage(code: currentAppLanguageCode) {
                lessonIsAvailableInAppLanguage = resource.supportsLanguage(languageId: appLanguage.id)
            }
            else {
                lessonIsAvailableInAppLanguage = false
            }
             
            let availabilityInAppLanguage: String
            let appLanguageName: String = localeLanguageName.getDisplayName(forLanguageCode: currentAppLanguageCode, translatedInLanguageCode: currentAppLanguageCode) ?? ""
            
            if lessonIsAvailableInAppLanguage {
                availabilityInAppLanguage = appLanguageName + " ✓"
            }
            else {
                let languageNotAvailable: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: currentAppLanguageCode, key: "lessonCard.languageNotAvailable")
                
                availabilityInAppLanguage = String(
                    format: languageNotAvailable,
                    locale: Locale(identifier: currentAppLanguageCode),
                    appLanguageName
                ) + " x"
            }
 
            return LessonListItemDomainModel(
                analyticsToolName: resource.abbreviation,
                availabilityInAppLanguage: availabilityInAppLanguage,
                bannerImageId: resource.attrBanner,
                dataModelId: resource.id,
                name: lessonNameInAppLanguage
            )
        }
        
        return Just(lessonListItems)
            .eraseToAnyPublisher()
    }
    
    func observeLessonsChangedPublisher() -> AnyPublisher<Void, Never> {
        return resourcesRepository.getResourcesChangedPublisher()
            .eraseToAnyPublisher()
    }
}
