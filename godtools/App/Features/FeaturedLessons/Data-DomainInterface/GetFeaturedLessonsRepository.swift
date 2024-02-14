//
//  GetFeaturedLessonsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetFeaturedLessonsRepository: GetFeaturedLessonsRepositoryInterface {
    
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
    
    func getFeaturedLessonsPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[FeaturedLessonDomainModel], Never> {
        
        return resourcesRepository.getResourcesChangedPublisher()
            .flatMap({ (resourcesChanged: Void) -> AnyPublisher<[FeaturedLessonDomainModel], Never> in
                
                let featuredLessonsDataModels: [ResourceModel] = self.resourcesRepository.getFeaturedLessons(sorted: true)
                
                let featuredLessons: [FeaturedLessonDomainModel] = featuredLessonsDataModels.map { (resource: ResourceModel) in

                    let lessonNameInAppLanguage: String
                    let lessonIsAvailableInAppLanguage: Bool
                    
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
         
                    return FeaturedLessonDomainModel(
                        analyticsToolName: resource.abbreviation,
                        availabilityInAppLanguage: availabilityInAppLanguage,
                        bannerImageId: resource.attrBanner,
                        dataModelId: resource.id,
                        name: lessonNameInAppLanguage
                    )
                }
                
                return Just(featuredLessons)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
