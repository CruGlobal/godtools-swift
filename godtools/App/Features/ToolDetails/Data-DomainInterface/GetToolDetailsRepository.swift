//
//  GetToolDetailsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolDetailsRepository: GetToolDetailsRepositoryInterface {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let translationsRepository: TranslationsRepository
    private let localizationServices: LocalizationServicesInterface
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, translationsRepository: TranslationsRepository, localizationServices: LocalizationServicesInterface, getTranslatedLanguageName: GetTranslatedLanguageName, favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.translationsRepository = translationsRepository
        self.localizationServices = localizationServices
        self.getTranslatedLanguageName = getTranslatedLanguageName
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func getDetailsPublisher(toolId: String, translateInLanguage: BCP47LanguageIdentifier, toolPrimaryLanguage: BCP47LanguageIdentifier, toolParallelLanguage: BCP47LanguageIdentifier?) -> AnyPublisher<ToolDetailsDomainModel, Error> {
        
        let noToolDomainModel = ToolDetailsDomainModel(
            analyticsToolAbbreviation: "",
            aboutDescription: "",
            bibleReferences: "",
            conversationStarters: "",
            isFavorited: false,
            languagesAvailable: "",
            name: "",
            numberOfViews: "",
            versions: [],
            versionsDescription: ""
        )
        
        guard let toolDataModel = resourcesRepository.persistence.getDataModelNonThrowing(id: toolId) else {
            return Just(noToolDomainModel)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    
        let translation: TranslationDataModel
        if let appLanguagetranslation = translationsRepository.cache.getLatestTranslation(resourceId: toolId, languageCode: translateInLanguage) {
            
            translation = appLanguagetranslation
        }
        else if let defaultTranslation = translationsRepository.cache.getLatestTranslation(resourceId: toolId, languageCode: toolDataModel.attrDefaultLocale) {
            
            translation = defaultTranslation
        }
        else {
            return Just(noToolDomainModel)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let numberOfViewsString: String = String(
            format: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "total_views").capitalized,
            locale: Locale(identifier: translateInLanguage),
            toolDataModel.totalViews
        )
        
        let languageIds: [String] = toolDataModel.getLanguageIds()
        
        return Publishers.CombineLatest(
            getLanguagesAvailablePublisher(languageIds: languageIds, translateInLanguage: translateInLanguage),
            getToolVersionsPublisher(
                toolDataModel: toolDataModel,
                translateInLanguage: translateInLanguage,
                toolPrimaryLanguage: toolPrimaryLanguage,
                toolParallelLanguage: toolParallelLanguage
            )
        )
        .map { (languagesAvailable: String, toolVersions: [ToolVersionDomainModel]) in
            
            let toolDetails = ToolDetailsDomainModel(
                analyticsToolAbbreviation: toolDataModel.abbreviation,
                aboutDescription: translation.translatedDescription,
                bibleReferences: translation.toolDetailsBibleReferences,
                conversationStarters: translation.toolDetailsConversationStarters,
                isFavorited: self.favoritedResourcesRepository.getResourceIsFavorited(id: toolId),
                languagesAvailable: languagesAvailable,
                name: translation.translatedName,
                numberOfViews: numberOfViewsString,
                versions: toolVersions,
                versionsDescription: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "toolDetails.versions.message")
            )
            
            return toolDetails
        }
        .eraseToAnyPublisher()
    }
    
    private func getLanguagesAvailablePublisher(languageIds: [String], translateInLanguage: BCP47LanguageIdentifier) -> AnyPublisher<String, Error> {
        
        return languagesRepository
            .persistence
            .getDataModelsPublisher(getOption: .objectsByIds(ids: languageIds))
            .map { (languagesDataModels: [LanguageDataModel]) in
                
                let languageNamesTranslatedInToolLanguage: [String] = languagesDataModels.map { (languageDataModel: LanguageDataModel) in
                    self.getTranslatedLanguageName.getLanguageName(language: languageDataModel, translatedInLanguage: translateInLanguage)
                }
                
                let languagesAvailable: String = languageNamesTranslatedInToolLanguage.map({$0}).sorted(by: { $0 < $1 }).joined(separator: ", ")
                
                return languagesAvailable
            }
            .eraseToAnyPublisher()
    }
    
    private func getToolVersionsPublisher(toolDataModel: ResourceDataModel, translateInLanguage: BCP47LanguageIdentifier, toolPrimaryLanguage: BCP47LanguageIdentifier, toolParallelLanguage: BCP47LanguageIdentifier?) -> AnyPublisher<[ToolVersionDomainModel], Error> {
        
        guard let metaToolId = toolDataModel.metatoolId, !metaToolId.isEmpty else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return resourcesRepository.cache
            .getResourceVariantsPublisher(resourceId: metaToolId)
            .map { (resourceVariants: [ResourceDataModel]) in
                
                let toolPrimaryLanguageName: String = self.getTranslatedLanguageName.getLanguageName(language: toolPrimaryLanguage, translatedInLanguage: translateInLanguage)
                
                let toolParallelLanguageName: String?
                
                if let toolParallelLanguage = toolParallelLanguage {
                    toolParallelLanguageName = self.getTranslatedLanguageName.getLanguageName(language: toolParallelLanguage, translatedInLanguage: translateInLanguage)
                }
                else {
                    toolParallelLanguageName = nil
                }
                        
                var toolVersions: [ToolVersionDomainModel] = Array()
                
                for resourceVariant in resourceVariants {
                    
                    let name: String
                    let description: String
                    
                    if let appLanguageTranslation = self.translationsRepository.cache.getLatestTranslation(resourceId: resourceVariant.id, languageCode: translateInLanguage) {
                        
                        name = appLanguageTranslation.translatedName
                        description = appLanguageTranslation.translatedTagline
                    }
                    else if let defaultTranslation = self.translationsRepository.cache.getLatestTranslation(resourceId: resourceVariant.id, languageCode: resourceVariant.attrDefaultLocale) {
                        
                        name = defaultTranslation.translatedName
                        description = defaultTranslation.translatedTagline
                    }
                    else {
                        
                        name = resourceVariant.name
                        description = resourceVariant.resourceDescription
                    }
                    
                    let toolVersion = ToolVersionDomainModel(
                        analyticsToolAbbreviation: resourceVariant.abbreviation,
                        bannerImageId: resourceVariant.attrBanner,
                        dataModelId: resourceVariant.id,
                        description: description,
                        name: name,
                        numberOfLanguages: self.getNumberOfLanguages(translateInLanguage: translateInLanguage, numberOfLanguages: resourceVariant.getLanguageIds().count),
                        toolLanguageName: toolPrimaryLanguageName,
                        toolLanguageNameIsSupported: self.getToolSupportsLanguage(resource: resourceVariant, language: toolPrimaryLanguage),
                        toolParallelLanguageName: toolParallelLanguageName,
                        toolParallelLanguageNameIsSupported: self.getToolSupportsLanguage(resource: resourceVariant, language: toolParallelLanguage)
                    )
                    
                    toolVersions.append(toolVersion)
                }
                    
                return toolVersions
            }
            .eraseToAnyPublisher()
    }
    
    private func getNumberOfLanguages(translateInLanguage: BCP47LanguageIdentifier, numberOfLanguages: Int) -> String {
        
        let localizedNumberOfLanguages = self.localizationServices.stringForLocaleElseSystemElseEnglish(
            localeIdentifier: translateInLanguage,
            key: LocalizableStringDictKeys.toolDetailsToolVersionNumberOfLanguages.key
        )
        
        let stringLocaleFormat = String(
            format: localizedNumberOfLanguages,
            locale: Locale(identifier: translateInLanguage),
            numberOfLanguages
        )
                            
        return stringLocaleFormat
    }
    
    private func getToolSupportsLanguage(resource: ResourceDataModel, language: AppLanguageDomainModel?) -> Bool {
        
        guard let language = language else {
            return false
        }
        
        guard let languageModel = languagesRepository.cache.getCachedLanguage(code: language) else {
            return false
        }
        
        return resource.getLanguageIds().contains(languageModel.id)
    }
}
