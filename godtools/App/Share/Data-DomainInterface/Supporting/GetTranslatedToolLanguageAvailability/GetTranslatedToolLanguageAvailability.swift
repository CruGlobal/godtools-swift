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
    
    func getTranslatedLanguageAvailability(toolId: String, language: LanguageModel, translateInLanguage: AppLanguageDomainModel) -> ToolLanguageAvailabilityDomainModel {
        
        guard let resource = resourcesRepository.getResource(id: toolId) else {
            return failedToDetermineLanguageAvailability
        }
        
        return getTranslatedLanguageAvailability(resource: resource, language: language, translateInLanguage: translateInLanguage)
    }
    
    func getTranslatedLanguageAvailability(resource: ResourceModel, language: AppLanguageDomainModel, translateInLanguage: AppLanguageDomainModel) -> ToolLanguageAvailabilityDomainModel {
        
        guard let languageModel = languagesRepository.getLanguage(code: language) else {
            return failedToDetermineLanguageAvailability
        }
        
        return getTranslatedLanguageAvailability(resource: resource, language: languageModel, translateInLanguage: translateInLanguage)
    }
    
    func getTranslatedLanguageAvailability(resource: ResourceModel, language: LanguageModel, translateInLanguage: AppLanguageDomainModel) -> ToolLanguageAvailabilityDomainModel {
        
        guard let translateInLanguageModel = languagesRepository.getLanguage(code: translateInLanguage) else {
            return failedToDetermineLanguageAvailability
        }
        
        return getTranslatedLanguageAvailability(resource: resource, language: language, translateInLanguage: translateInLanguageModel)
    }
    
    func getTranslatedLanguageAvailability(resource: ResourceModel, language: LanguageModel, translateInLanguage: LanguageModel) -> ToolLanguageAvailabilityDomainModel {
        
        let translatedLanguageName: String = translatedLanguageNameRepository.getLanguageName(language: language, translatedInLanguage: translateInLanguage.code)
        
        let resourceSupportsLanguage: Bool = resource.supportsLanguage(languageId: language.id)
        
        let availabilityString: String
        
        if resourceSupportsLanguage {
            
            availabilityString = translatedLanguageName + " ✓"
        }
        else {
            
            let languageNotAvailable: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage.code, key: "lessonCard.languageNotAvailable")
            
            availabilityString = String(format: languageNotAvailable, locale: Locale(identifier: translateInLanguage.code), translatedLanguageName)
        }
        
        return ToolLanguageAvailabilityDomainModel(
            availabilityString: availabilityString,
            isAvailable: resourceSupportsLanguage
        )
    }
}
