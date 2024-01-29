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
    
    func getDetailsPublisher(tool: ToolDomainModel, translateInLanguage: BCP47LanguageIdentifier, toolPrimaryLanguage: BCP47LanguageIdentifier, toolParallelLanguage: BCP47LanguageIdentifier?) -> AnyPublisher<ToolDetailsDomainModel, Never> {
        
        let noToolDomainModel = ToolDetailsDomainModel(
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
        
        guard let toolDataModel = resourcesRepository.getResource(id: tool.dataModelId) else {
            return Just(noToolDomainModel)
                .eraseToAnyPublisher()
        }
        
        guard let translation = translationsRepository.getLatestTranslation(resourceId: tool.dataModelId, languageCode: translateInLanguage) else {
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
            aboutDescription: translation.translatedDescription,
            bibleReferences: translation.toolDetailsBibleReferences,
            conversationStarters: translation.toolDetailsConversationStarters,
            isFavorited: favoritedResourcesRepository.getResourceIsFavorited(id: tool.dataModelId),
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
        
        let versions: [ToolVersionDomainModel] = resourceVariants.compactMap { (variantDataModel: ResourceModel) in
            
            guard let translation = self.translationsRepository.getLatestTranslation(resourceId: variantDataModel.id, languageCode: translateInLanguage) else {
                return nil
            }
            
            let numberOfLanguagesString: String = String(
                format: localizedTotalLanguages,
                locale: Locale(identifier: translateInLanguage),
                variantDataModel.languageIds.count
            )
            
            return ToolVersionDomainModel(
                bannerImageId: variantDataModel.attrBanner,
                dataModelId: variantDataModel.id,
                description: translation.translatedTagline,
                name: translation.translatedName,
                numberOfLanguages: numberOfLanguagesString,
                toolLanguageName: toolPrimaryLanguageName ?? "",
                toolLanguageNameIsSupported: getToolSupportsLanguage(resource: variantDataModel, language: toolPrimaryLanguage),
                toolParallelLanguageName: toolParallelLanguageName,
                toolParallelLanguageNameIsSupported: getToolSupportsLanguage(resource: variantDataModel, language: toolParallelLanguage)
            )
        }
        
        return versions
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
