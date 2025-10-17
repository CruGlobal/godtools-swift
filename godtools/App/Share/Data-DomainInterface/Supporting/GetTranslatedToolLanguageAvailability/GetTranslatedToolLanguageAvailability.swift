//
//  GetTranslatedToolLanguageAvailability.swift
//  godtools
//
//  Created by Levi Eggert on 2/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class GetTranslatedToolLanguageAvailability {
    
    static let languageAvailableCheck: String = "✓"
    static let localizedKeyLanguageNotAvailable: String = "lessonCard.languageNotAvailable"
    
    private let localizationServices: LocalizationServicesInterface
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    
    init(localizationServices: LocalizationServicesInterface, resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, getTranslatedLanguageName: GetTranslatedLanguageName) {
        
        self.localizationServices = localizationServices
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedLanguageName = getTranslatedLanguageName
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
        
        let translatedLanguageName: String = getTranslatedLanguageName.getLanguageName(language: language, translatedInLanguage: translateInLanguage.code)
        
        let resourceSupportsLanguage: Bool = resource.supportsLanguage(languageId: language.id)
        
        let availabilityString: String
        
        if resourceSupportsLanguage {
            
            availabilityString = translatedLanguageName + " " + Self.languageAvailableCheck
        }
        else {
            
            let languageNotAvailable: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage.code, key: Self.localizedKeyLanguageNotAvailable)
            
            availabilityString = String(format: languageNotAvailable, locale: Locale(identifier: translateInLanguage.code), translatedLanguageName)
        }
        
        return ToolLanguageAvailabilityDomainModel(
            availabilityString: availabilityString,
            isAvailable: resourceSupportsLanguage
        )
    }
}
