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
    
    init(resourcesCache: ResourcesCache, localizationServices: LocalizationServices, languageSettingsService: LanguageSettingsService, getToolLanguagesUseCase: GetToolLanguagesUseCase) {
        
        self.resourcesCache = resourcesCache
        self.localizationServices = localizationServices
        self.languageSettingsService = languageSettingsService
        self.getToolLanguagesUseCase = getToolLanguagesUseCase
    }
    
    func getToolVersions(resourceId: String) -> [ToolVersion] {
        
        let variants: [ResourceModel] = resourcesCache.getResourceVariants(resourceId: resourceId)
        
        guard !variants.isEmpty else {
            return []
        }
        
        return variants.map({
            getToolVersion(resource: $0)
        })
    }
    
    private func getToolVersion(resource: ResourceModel) -> ToolVersion {
        
        let toolLanguages: [ToolLanguageModel] = getToolLanguagesUseCase.getToolLanguages(resource: resource)
                
        let name: String
        let languageBundle: Bundle
        
        // TODO: Another place that needs to be completed in GT-1625. ~Levi
        if let primaryLanguage = languageSettingsService.primaryLanguage.value, let primaryTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageId: primaryLanguage.id) {
            
            name = primaryTranslation.translatedName
            languageBundle = localizationServices.bundleLoader.bundleForResource(resourceName: primaryLanguage.code) ?? Bundle.main
        }
        else if let englishTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageCode: "en") {
            
            name = englishTranslation.translatedName
            languageBundle = localizationServices.bundleLoader.englishBundle ?? Bundle.main
        }
        else {
            
            name = resource.name
            languageBundle = localizationServices.bundleLoader.englishBundle ?? Bundle.main
        }
        
        return ToolVersion(
            id: resource.id,
            bannerImageId: resource.attrBanner,
            name: name,
            description: resource.resourceDescription,
            languages: String.localizedStringWithFormat(localizationServices.stringForBundle(bundle: languageBundle, key: "total_languages"), toolLanguages.count),
            primaryLanguageSupported: "",
            parallelLanguageSupported: ""
        )
    }
}
