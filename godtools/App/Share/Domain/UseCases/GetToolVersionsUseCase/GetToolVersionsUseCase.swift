//
//  GetToolVersionsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetToolVersionsUseCase {
    
    private let resourcesCache: ResourcesCache
    private let localizationServices: LocalizationServices
    private let languageSettingsService: LanguageSettingsService
    private let getToolLanguagesUseCase: GetToolLanguagesUseCase
    private let getTranslatedLanguageUseCase: GetTranslatedLanguageUseCase
    
    init(resourcesCache: ResourcesCache, localizationServices: LocalizationServices, languageSettingsService: LanguageSettingsService, getToolLanguagesUseCase: GetToolLanguagesUseCase, getTranslatedLanguageUseCase: GetTranslatedLanguageUseCase) {
        
        self.resourcesCache = resourcesCache
        self.localizationServices = localizationServices
        self.languageSettingsService = languageSettingsService
        self.getToolLanguagesUseCase = getToolLanguagesUseCase
        self.getTranslatedLanguageUseCase = getTranslatedLanguageUseCase
    }
    
    func getToolVersions(resourceId: String) -> [ToolVersionDomainModel] {
        
        guard let resource = resourcesCache.getResource(id: resourceId) else {
            return []
        }
        
        let resourceVersions: [ResourceModel] = resourcesCache.getResourceVariants(resourceId: resourceId)
        
        guard !resourceVersions.isEmpty else {
            return []
        }
        
        return resourceVersions.map({
            getToolVersion(resource: resource, resourceVersion: $0)
        })
    }
    
    private func getToolVersion(resource: ResourceModel, resourceVersion: ResourceModel) -> ToolVersionDomainModel {
        
        let toolLanguages: [ToolLanguageModel] = getToolLanguagesUseCase.getToolLanguages(resource: resourceVersion)
        let toolLanguagesIds: [String] = toolLanguages.map({$0.id})
                
        let name: String
        let description: String
        let languageBundle: Bundle
        
        // TODO: Another place that needs to be completed in GT-1625. ~Levi
        if let primaryLanguage = languageSettingsService.primaryLanguage.value, let primaryTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resourceVersion.id, languageId: primaryLanguage.id) {
            
            name = primaryTranslation.translatedName
            description = primaryTranslation.translatedTagline
            languageBundle = localizationServices.bundleLoader.bundleForResource(resourceName: primaryLanguage.code) ?? Bundle.main
        }
        else if let englishTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resourceVersion.id, languageCode: "en") {
            
            name = englishTranslation.translatedName
            description = englishTranslation.translatedTagline
            languageBundle = localizationServices.bundleLoader.englishBundle ?? Bundle.main
        }
        else {
            
            name = resourceVersion.name
            description = resource.resourceDescription
            languageBundle = localizationServices.bundleLoader.englishBundle ?? Bundle.main
        }
        
        let primaryLanguage: String?
        let supportsPrimaryLanguage: Bool
        
        let parallelLanguage: String?
        let supportsParallelLanguage: Bool
        
        if let primaryLanguageId = languageSettingsService.primaryLanguage.value?.id {
            
            primaryLanguage = getTranslatedLanguageUseCase.getTranslatedLanguage(languageId: primaryLanguageId)?.name
            supportsPrimaryLanguage = toolLanguagesIds.contains(primaryLanguageId)
        }
        else {
            
            primaryLanguage = nil
            supportsPrimaryLanguage = false
        }
        
        if let parallelLanguageId = languageSettingsService.parallelLanguage.value?.id {
            
            parallelLanguage = getTranslatedLanguageUseCase.getTranslatedLanguage(languageId: parallelLanguageId)?.name
            supportsParallelLanguage = toolLanguagesIds.contains(parallelLanguageId)
        }
        else {
            
            parallelLanguage = nil
            supportsParallelLanguage = false
        }
                
        return ToolVersionDomainModel(
            id: resourceVersion.id,
            bannerImageId: resourceVersion.attrBanner,
            name: name,
            description: description,
            numberOfLanguages: toolLanguages.count,
            numberOfLanguagesString: String.localizedStringWithFormat(localizationServices.stringForBundle(bundle: languageBundle, key: "total_languages"), toolLanguages.count),
            primaryLanguage: primaryLanguage,
            primaryLanguageIsSupported: supportsPrimaryLanguage,
            parallelLanguage: parallelLanguage,
            parallelLanguageIsSupported: supportsParallelLanguage,
            isDefaultVersion: resourceVersion.id == resource.defaultVariantId
        )
    }
}
