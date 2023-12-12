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
    
    func getLessonsListPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[LessonListItemDomainModel], Never> {
        
        return resourcesRepository
            .getResourcesChangedPublisher()
            .flatMap({ (resourcesDidChange: Void) -> AnyPublisher<[LessonListItemDomainModel], Never> in
                
                let lessons: [ResourceModel] = self.resourcesRepository.getAllLessons(sorted: true)
                
                let lessonListItems: [LessonListItemDomainModel] = lessons.map { (resource: ResourceModel) in
                    
                    let lessonIsAvailableInAppLanguage: Bool
                    let lessonNameInAppLanguage: String
                    
                    if let translation = self.translationsRepository.getLatestTranslation(resourceId: resource.id, languageCode: appLanguage) {
                        lessonNameInAppLanguage = translation.translatedName
                    }
                    else {
                        lessonNameInAppLanguage = ""
                    }
                    
                    if let appLanguage = self.languagesRepository.getLanguage(code: appLanguage) {
                        lessonIsAvailableInAppLanguage = resource.supportsLanguage(languageId: appLanguage.id)
                    }
                    else {
                        lessonIsAvailableInAppLanguage = false
                    }
                    
                    let availabilityInAppLanguage: String
                    let appLanguageName: String = self.localeLanguageName.getLanguageName(forLanguageCode: appLanguage, translatedInLanguageId: appLanguage) ?? ""
                    
                    if lessonIsAvailableInAppLanguage {
                        availabilityInAppLanguage = appLanguageName + " ✓"
                    }
                    else {
                        let languageNotAvailable: String = self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "lessonCard.languageNotAvailable")
                        
                        availabilityInAppLanguage = String(
                            format: languageNotAvailable,
                            locale: Locale(identifier: appLanguage),
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
            })
            .eraseToAnyPublisher()
    }
}
