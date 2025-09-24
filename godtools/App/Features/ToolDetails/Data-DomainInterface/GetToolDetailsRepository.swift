//
//  GetToolDetailsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import LocalizationServices

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
    
    func getDetailsPublisher(toolId: String, translateInLanguage: BCP47LanguageIdentifier, toolPrimaryLanguage: BCP47LanguageIdentifier, toolParallelLanguage: BCP47LanguageIdentifier?) -> AnyPublisher<ToolDetailsDomainModel, Never> {
        
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
        
        guard let toolDataModel = resourcesRepository.persistence.getObject(id: toolId) else {
            return Just(noToolDomainModel)
                .eraseToAnyPublisher()
        }
    
        let translation: TranslationDataModel
        if let appLanguagetranslation = translationsRepository.getCachedLatestTranslation(resourceId: toolId, languageCode: translateInLanguage) {
            
            translation = appLanguagetranslation
        }
        else if let defaultTranslation = translationsRepository.getCachedLatestTranslation(resourceId: toolId, languageCode: toolDataModel.attrDefaultLocale) {
            
            translation = defaultTranslation
        }
        else {
            return Just(noToolDomainModel)
                .eraseToAnyPublisher()
        }
        
        let numberOfViewsString: String = String(
            format: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "total_views").capitalized,
            locale: Locale(identifier: translateInLanguage),
            toolDataModel.totalViews
        )
        
        let languagesDataModels: [LanguageDataModel] = languagesRepository.persistence.getObjects(ids: toolDataModel.getLanguageIds())
        
        let languageNamesTranslatedInToolLanguage: [String] = languagesDataModels.map { (languageDataModel: LanguageDataModel) in
            self.getTranslatedLanguageName.getLanguageName(language: languageDataModel, translatedInLanguage: translateInLanguage)
        }
        
        let languagesAvailable: String = languageNamesTranslatedInToolLanguage.map({$0}).sorted(by: { $0 < $1 }).joined(separator: ", ")
        
        let toolDetails = ToolDetailsDomainModel(
            analyticsToolAbbreviation: toolDataModel.abbreviation,
            aboutDescription: translation.translatedDescription,
            bibleReferences: translation.toolDetailsBibleReferences,
            conversationStarters: translation.toolDetailsConversationStarters,
            isFavorited: favoritedResourcesRepository.getResourceIsFavorited(id: toolId),
            languagesAvailable: languagesAvailable,
            name: translation.translatedName,
            numberOfViews: numberOfViewsString,
            versions: getToolVersions(toolDataModel: toolDataModel, translateInLanguage: translateInLanguage, toolPrimaryLanguage: toolPrimaryLanguage, toolParallelLanguage: toolParallelLanguage),
            versionsDescription: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "toolDetails.versions.message")
        )
        
        return Just(toolDetails)
            .eraseToAnyPublisher()
    }
    
    private func getToolVersions(toolDataModel: ResourceDataModel, translateInLanguage: BCP47LanguageIdentifier, toolPrimaryLanguage: BCP47LanguageIdentifier, toolParallelLanguage: BCP47LanguageIdentifier?) -> [ToolVersionDomainModel] {
        
        let resourceVariants: [ResourceDataModel]
        
        if let metatoolId = toolDataModel.metatoolId, !metatoolId.isEmpty {
            resourceVariants = resourcesRepository.getResourceVariants(resourceId: metatoolId)
        }
        else {
            resourceVariants = []
        }
        
        let toolPrimaryLanguageName: String = getTranslatedLanguageName.getLanguageName(language: toolPrimaryLanguage, translatedInLanguage: translateInLanguage)
        
        let toolParallelLanguageName: String?
        
        if let toolParallelLanguage = toolParallelLanguage {
            toolParallelLanguageName = getTranslatedLanguageName.getLanguageName(language: toolParallelLanguage, translatedInLanguage: translateInLanguage)
        }
        else {
            toolParallelLanguageName = nil
        }
                
        var toolVersions: [ToolVersionDomainModel] = Array()
        
        for resourceVariant in resourceVariants {
            
            let name: String
            let description: String
            
            if let appLanguageTranslation = translationsRepository.getCachedLatestTranslation(resourceId: resourceVariant.id, languageCode: translateInLanguage) {
                
                name = appLanguageTranslation.translatedName
                description = appLanguageTranslation.translatedTagline
            }
            else if let defaultTranslation = translationsRepository.getCachedLatestTranslation(resourceId: resourceVariant.id, languageCode: resourceVariant.attrDefaultLocale) {
                
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
                numberOfLanguages: getNumberOfLanguages(translateInLanguage: translateInLanguage, numberOfLanguages: resourceVariant.getLanguageIds().count),
                toolLanguageName: toolPrimaryLanguageName,
                toolLanguageNameIsSupported: getToolSupportsLanguage(resource: resourceVariant, language: toolPrimaryLanguage),
                toolParallelLanguageName: toolParallelLanguageName,
                toolParallelLanguageNameIsSupported: getToolSupportsLanguage(resource: resourceVariant, language: toolParallelLanguage)
            )
            
            toolVersions.append(toolVersion)
        }
        
        return toolVersions
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
        
        guard let languageModel = languagesRepository.getCachedLanguage(code: language) else {
            return false
        }
        
        return resource.getLanguageIds().contains(languageModel.id)
    }
}
