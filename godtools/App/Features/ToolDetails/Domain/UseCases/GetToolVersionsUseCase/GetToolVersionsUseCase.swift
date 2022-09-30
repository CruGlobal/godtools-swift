//
//  GetToolVersionsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetToolVersionsUseCase {
    
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    private let localizationServices: LocalizationServices
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let getToolLanguagesUseCase: GetToolLanguagesUseCase
    
    init(resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getToolLanguagesUseCase: GetToolLanguagesUseCase) {
        
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
        self.localizationServices = localizationServices
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.getToolLanguagesUseCase = getToolLanguagesUseCase
    }
    
    func getToolVersions(resourceId: String) -> [ToolVersionDomainModel] {
        
        guard let resource = resourcesRepository.getResource(id: resourceId) else {
            return []
        }
        
        let resourceVersions: [ResourceModel] = resourcesRepository.getResourceVariants(resourceId: resourceId)
            .filter({!$0.isHidden})
        
        guard !resourceVersions.isEmpty else {
            return []
        }
        
        return resourceVersions.map({
            getToolVersion(resource: resource, resourceVersion: $0)
        })
    }
    
    private func getToolVersion(resource: ResourceModel, resourceVersion: ResourceModel) -> ToolVersionDomainModel {
        
        let toolLanguages: [LanguageDomainModel] = getToolLanguagesUseCase.getToolLanguages(resource: resourceVersion)
        let toolLanguagesIds: [String] = toolLanguages.map({$0.dataModelId})
                
        let primaryLanguage: LanguageDomainModel? = getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()
        
        let name: String
        let description: String
        let languageBundle: Bundle
        
        // TODO: Another place that needs to be completed in GT-1625. ~Levi
        if let primaryLanguage = primaryLanguage, let primaryTranslation = translationsRepository.getLatestTranslation(resourceId: resourceVersion.id, languageId: primaryLanguage.id) {
            
            name = primaryTranslation.translatedName
            description = primaryTranslation.translatedTagline
            languageBundle = localizationServices.bundleLoader.bundleForResource(resourceName: primaryLanguage.localeIdentifier) ?? Bundle.main
        }
        else if let englishTranslation = translationsRepository.getLatestTranslation(resourceId: resourceVersion.id, languageCode: "en") {
            
            name = englishTranslation.translatedName
            description = englishTranslation.translatedTagline
            languageBundle = localizationServices.bundleLoader.englishBundle ?? Bundle.main
        }
        else {
            
            name = resourceVersion.name
            description = resource.resourceDescription
            languageBundle = localizationServices.bundleLoader.englishBundle ?? Bundle.main
        }
        
        let primaryLanguageTranslatedName: String?
        let supportsPrimaryLanguage: Bool
        
        let parallelLanguageTranslatedName: String?
        let supportsParallelLanguage: Bool
        
        if let primaryLanguage = primaryLanguage {
            
            primaryLanguageTranslatedName = primaryLanguage.translatedName
            supportsPrimaryLanguage = toolLanguagesIds.contains(primaryLanguage.dataModelId)
        }
        else {
            
            primaryLanguageTranslatedName = nil
            supportsPrimaryLanguage = false
        }
        
        if let parallelLanguage = getSettingsParallelLanguageUseCase.getParallelLanguage() {
            
            parallelLanguageTranslatedName = parallelLanguage.translatedName
            supportsParallelLanguage = toolLanguagesIds.contains(parallelLanguage.dataModelId)
        }
        else {
            
            parallelLanguageTranslatedName = nil
            supportsParallelLanguage = false
        }
                
        return ToolVersionDomainModel(
            bannerImageId: resourceVersion.attrBanner,
            dataModelId: resourceVersion.id,
            name: name,
            description: description,
            numberOfLanguages: toolLanguages.count,
            numberOfLanguagesString: String.localizedStringWithFormat(localizationServices.stringForBundle(bundle: languageBundle, key: "total_languages"), toolLanguages.count),
            primaryLanguage: primaryLanguageTranslatedName,
            primaryLanguageIsSupported: supportsPrimaryLanguage,
            parallelLanguage: parallelLanguageTranslatedName,
            parallelLanguageIsSupported: supportsParallelLanguage,
            isDefaultVersion: resourceVersion.id == resource.defaultVariantId
        )
    }
}
