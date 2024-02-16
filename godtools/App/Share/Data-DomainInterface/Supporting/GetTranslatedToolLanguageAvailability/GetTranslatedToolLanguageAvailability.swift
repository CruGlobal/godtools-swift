//
//  GetTranslatedToolLanguageAvailability.swift
//  godtools
//
//  Created by Levi Eggert on 2/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class GetTranslatedToolLanguageAvailability {
    
    private let localizationServices: LocalizationServices
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let translatedLanguageNameRepository: TranslatedLanguageNameRepository
    
    init(localizationServices: LocalizationServices, resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, translatedLanguageNameRepository: TranslatedLanguageNameRepository) {
        
        self.localizationServices = localizationServices
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.translatedLanguageNameRepository = translatedLanguageNameRepository
    }
    
    private var failedToDetermineLanguageAvailability: ToolLanguageAvailabilityDomainModel {
        return ToolLanguageAvailabilityDomainModel(availabilityString: "", isAvailable: false)
    }
    
    func getTranslatedLanguageAvailability(toolId: String, translateInLanguage: AppLanguageDomainModel) -> ToolLanguageAvailabilityDomainModel {
        
        guard let resource = resourcesRepository.getResource(id: toolId) else {
            return failedToDetermineLanguageAvailability
        }
        
        return getTranslatedLanguageAvailability(resource: resource, translateInLanguage: translateInLanguage)
    }
    
    func getTranslatedLanguageAvailability(resource: ResourceModel, translateInLanguage: AppLanguageDomainModel) -> ToolLanguageAvailabilityDomainModel {
        
        guard let language = languagesRepository.getLanguage(code: translateInLanguage) else {
            return failedToDetermineLanguageAvailability
        }
        
        return getTranslatedLanguageAvailability(resource: resource, language: language, translateInLanguage: translateInLanguage)
    }
    
    func getTranslatedLanguageAvailability(resource: ResourceModel, language: LanguageModel, translateInLanguage: AppLanguageDomainModel) -> ToolLanguageAvailabilityDomainModel {
        
        let translatedLanguageName: String = translatedLanguageNameRepository.getLanguageName(language: translateInLanguage, translatedInLanguage: translateInLanguage)
        
        let resourceSupportsLanguage: Bool = resource.supportsLanguage(languageId: language.id)
        
        let availabilityString: String
        
        if resourceSupportsLanguage {
            
            availabilityString = translatedLanguageName + " ✓"
        }
        else {
            
            let languageNotAvailable: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "lessonCard.languageNotAvailable")
            
            availabilityString = String(format: languageNotAvailable, locale: Locale(identifier: translateInLanguage), translatedLanguageName)
        }
        
        return ToolLanguageAvailabilityDomainModel(
            availabilityString: availabilityString,
            isAvailable: resourceSupportsLanguage
        )
    }
}
