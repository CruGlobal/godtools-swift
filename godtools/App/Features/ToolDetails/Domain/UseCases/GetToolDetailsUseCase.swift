//
//  GetToolDetailsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/30/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetToolDetailsUseCase: Sendable {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let translationsRepository: TranslationsRepository
    private let localizationServices: LocalizationServicesInterface
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(
        resourcesRepository: ResourcesRepository,
        languagesRepository: LanguagesRepository,
        translationsRepository: TranslationsRepository,
        localizationServices: LocalizationServicesInterface,
        getTranslatedLanguageName: GetTranslatedLanguageName,
        favoritedResourcesRepository: FavoritedResourcesRepository
    ) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.translationsRepository = translationsRepository
        self.localizationServices = localizationServices
        self.getTranslatedLanguageName = getTranslatedLanguageName
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func execute(
        toolId: String,
        appLanguage: BCP47LanguageIdentifier,
        toolPrimaryLanguage: BCP47LanguageIdentifier,
        toolParallelLanguage: BCP47LanguageIdentifier?
    ) async throws -> ToolDetailsDomainModel {
        
        let toolDataModel: ResourceDataModel? = resourcesRepository.getResourceById(id: toolId)
        
        guard let toolDataModel = toolDataModel else {
            return ToolDetailsDomainModel.emptyValue
        }
    
        let translation: TranslationDataModel
        
        if let appLanguagetranslation = translationsRepository.getLatestTranslation(resourceId: toolId, languageCode: appLanguage) {
            translation = appLanguagetranslation
        }
        else if let defaultTranslation = translationsRepository.getLatestTranslation(resourceId: toolId, languageCode: toolDataModel.attrDefaultLocale) {
            translation = defaultTranslation
        }
        else {
            return ToolDetailsDomainModel.emptyValue
        }
        
        let numberOfViewsString: String = String(
            format: localizationServices.stringForLocaleElseEnglishElseKey(localeIdentifier: appLanguage, key: LocalizableStringKeys.totalViews.key).capitalized,
            locale: Locale(identifier: appLanguage),
            toolDataModel.totalViews
        )
        
        let languageIds: [String] = toolDataModel.languageIds
        
        let languagesAvailable: String = try await getLanguagesAvailable(languageIds: languageIds, translateInLanguage: appLanguage)
        
        let toolVersions: [ToolVersionDomainModel] = try await getToolVersions(
            toolDataModel: toolDataModel,
            translateInLanguage: appLanguage,
            toolPrimaryLanguage: toolPrimaryLanguage,
            toolParallelLanguage: toolParallelLanguage
        )
        
        let toolDetails = ToolDetailsDomainModel(
            analyticsToolAbbreviation: toolDataModel.abbreviation,
            aboutDescription: translation.translatedDescription,
            bibleReferences: translation.toolDetailsBibleReferences,
            conversationStarters: translation.toolDetailsConversationStarters,
            isFavorited: favoritedResourcesRepository.getResourceIsFavorited(id: toolId),
            languagesAvailable: languagesAvailable,
            name: translation.translatedName,
            numberOfViews: numberOfViewsString,
            versions: toolVersions,
            versionsDescription: localizationServices.stringForLocaleElseEnglishElseKey(localeIdentifier: appLanguage, key: LocalizableStringKeys.toolDetailsVersionsMessage.key)
        )
        
        return toolDetails
    }
    
    private func getLanguagesAvailable(languageIds: [String], translateInLanguage: BCP47LanguageIdentifier) async throws -> String {
        
        let languagesDataModels: [LanguageDataModel] = try await languagesRepository.getLanguagesByIds(ids: languageIds)
        
        var languageNamesTranslatedInToolLanguage: [String] = Array()

        for languageDataModel in languagesDataModels {

            languageNamesTranslatedInToolLanguage.append(
                await getTranslatedLanguageName.getLanguageName(language: languageDataModel, translatedInLanguage: translateInLanguage)
            )
        }
        
        let languagesAvailable: String = languageNamesTranslatedInToolLanguage.map({$0}).sorted(by: { $0 < $1 }).joined(separator: ", ")
        
        return languagesAvailable
    }
    
    private func getToolVersions(
        toolDataModel: ResourceDataModel,
        translateInLanguage: BCP47LanguageIdentifier,
        toolPrimaryLanguage: BCP47LanguageIdentifier,
        toolParallelLanguage: BCP47LanguageIdentifier?
    ) async throws -> [ToolVersionDomainModel] {
        
        guard let metaToolId = toolDataModel.metatoolId, !metaToolId.isEmpty else {
            return Array()
        }
        
        let resourceVariants: [ResourceDataModel] = try await resourcesRepository
            .getResourceVariants(resourceId: metaToolId)
        
        let toolPrimaryLanguageName: String = await getTranslatedLanguageName.getLanguageName(language: toolPrimaryLanguage, translatedInLanguage: translateInLanguage)
        
        let toolParallelLanguageName: String?
        
        if let toolParallelLanguage = toolParallelLanguage {
            toolParallelLanguageName = await getTranslatedLanguageName.getLanguageName(language: toolParallelLanguage, translatedInLanguage: translateInLanguage)
        }
        else {
            toolParallelLanguageName = nil
        }
                
        var toolVersions: [ToolVersionDomainModel] = Array()
        
        for resourceVariant in resourceVariants {
            
            let name: String
            let description: String
            
            if let appLanguageTranslation = translationsRepository.getLatestTranslation(resourceId: resourceVariant.id, languageCode: translateInLanguage) {
                
                name = appLanguageTranslation.translatedName
                description = appLanguageTranslation.translatedTagline
            }
            else if let defaultTranslation = translationsRepository.getLatestTranslation(resourceId: resourceVariant.id, languageCode: resourceVariant.attrDefaultLocale) {
                
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
                numberOfLanguages: getNumberOfLanguages(translateInLanguage: translateInLanguage, numberOfLanguages: resourceVariant.languageIds.count),
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
        
        let localizedNumberOfLanguages = localizationServices.stringForLocaleElseEnglishElseKey(
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
        
        guard let languageModel = languagesRepository.getLanguageByCode(code: language) else {
            return false
        }
        
        return resource.languageIds.contains(languageModel.id)
    }
}
