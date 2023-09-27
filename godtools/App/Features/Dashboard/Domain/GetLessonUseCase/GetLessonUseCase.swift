//
//  GetLessonUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 9/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetLessonUseCase {
    
    private let translationsRepository: TranslationsRepository
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    
    init(translationsRepository: TranslationsRepository, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase) {
        
        self.translationsRepository = translationsRepository
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
    }
    
    func getLesson(resource: ResourceModel, primaryLanguage: LanguageDomainModel?) -> LessonDomainModel {
        
        let title: String
        let languageAvailability: String
                
        if let primaryLanguage = primaryLanguage, let primaryTranslation = translationsRepository.getLatestTranslation(resourceId: resource.id, languageId: primaryLanguage.id) {
            
            title = primaryTranslation.translatedName
        }
        else if let englishTranslation = translationsRepository.getLatestTranslation(resourceId: resource.id, languageCode: LanguageCodeDomainModel.english.value) {
            
            title = englishTranslation.translatedName
        }
        else {
            
            title = resource.resourceDescription
        }
                
        languageAvailability = getLanguageAvailabilityUseCase.getLanguageAvailability(for: resource, language: primaryLanguage).availabilityString
                
        return LessonDomainModel(
            analyticsToolName: resource.abbreviation,
            bannerImageId: resource.attrBanner,
            dataModelId: resource.id,
            languageIds: resource.languageIds,
            languageAvailability: languageAvailability,
            title: title
        )
    }
}
