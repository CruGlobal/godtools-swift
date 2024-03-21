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
    private let localizationServices: LocalizationServices
    private let translatedLanguageNameRepository: TranslatedLanguageNameRepository
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, translationsRepository: TranslationsRepository, localizationServices: LocalizationServices, translatedLanguageNameRepository: TranslatedLanguageNameRepository, favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.translationsRepository = translationsRepository
        self.localizationServices = localizationServices
        self.translatedLanguageNameRepository = translatedLanguageNameRepository
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
        
        guard let toolDataModel = resourcesRepository.getResource(id: toolId) else {
            return Just(noToolDomainModel)
                .eraseToAnyPublisher()
        }
        
        guard let translation = translationsRepository.getLatestTranslation(resourceId: toolId, languageCode: translateInLanguage) else {
            return Just(noToolDomainModel)
                .eraseToAnyPublisher()
        }
        
        let numberOfViewsString: String = String(
            format: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "total_views").capitalized,
            locale: Locale(identifier: translateInLanguage),
            toolDataModel.totalViews
        )
        
        let languagesDataModels: [LanguageModel] = languagesRepository.getLanguages(ids: toolDataModel.languageIds)
        
        let languageNamesTranslatedInToolLanguage: [String] = languagesDataModels.map { (languageDataModel: LanguageModel) in
            self.translatedLanguageNameRepository.getLanguageName(language: languageDataModel.code, translatedInLanguage: translateInLanguage)
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
    
    private func getToolVersions(toolDataModel: ResourceModel, translateInLanguage: BCP47LanguageIdentifier, toolPrimaryLanguage: BCP47LanguageIdentifier, toolParallelLanguage: BCP47LanguageIdentifier?) -> [ToolVersionDomainModel] {
        
        let resourceVariants: [ResourceModel]
        
        if let metatoolId = toolDataModel.metatoolId, !metatoolId.isEmpty {
            resourceVariants = resourcesRepository.getResourceVariants(resourceId: metatoolId)
        }
        else {
            resourceVariants = []
        }
        
        let toolPrimaryLanguageName: String = translatedLanguageNameRepository.getLanguageName(language: toolPrimaryLanguage, translatedInLanguage: translateInLanguage)
        
        let toolParallelLanguageName: String?
        
        if let toolParallelLanguage = toolParallelLanguage {
            toolParallelLanguageName = translatedLanguageNameRepository.getLanguageName(language: toolParallelLanguage, translatedInLanguage: translateInLanguage)
        }
        else {
            toolParallelLanguageName = nil
        }
        
        let localizedTotalLanguages: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "total_languages")
        
        var toolVersions: [ToolVersionDomainModel] = Array()
        
        for resourceVariant in resourceVariants {
            
            let numberOfLanguagesString: String = String(
                format: localizedTotalLanguages,
                locale: Locale(identifier: translateInLanguage),
                resourceVariant.languageIds.count
            )
            
            let name: String
            let description: String
            
            if let appLanguageTranslation = translationsRepository.getLatestTranslation(resourceId: resourceVariant.id, languageCode: translateInLanguage) {
                
                name = appLanguageTranslation.translatedName
                description = appLanguageTranslation.translatedTagline
            }
            else if let englishTranslation = translationsRepository.getLatestTranslation(resourceId: resourceVariant.id, languageCode: LanguageCodeDomainModel.english.rawValue) {
                
                name = englishTranslation.translatedName
                description = englishTranslation.translatedTagline
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
                numberOfLanguages: numberOfLanguagesString,
                toolLanguageName: toolPrimaryLanguageName ?? "",
                toolLanguageNameIsSupported: getToolSupportsLanguage(resource: resourceVariant, language: toolPrimaryLanguage),
                toolParallelLanguageName: toolParallelLanguageName,
                toolParallelLanguageNameIsSupported: getToolSupportsLanguage(resource: resourceVariant, language: toolParallelLanguage)
            )
            
            toolVersions.append(toolVersion)
        }
        
        return toolVersions
    }
    
    private func getToolSupportsLanguage(resource: ResourceModel, language: AppLanguageDomainModel?) -> Bool {
        
        guard let language = language else {
            return false
        }
        
        guard let languageModel = languagesRepository.getLanguage(code: language) else {
            return false
        }
        
        return resource.languageIds.contains(languageModel.id)
    }
}
