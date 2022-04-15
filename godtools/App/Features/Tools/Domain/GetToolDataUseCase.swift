//
//  GetToolDataUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 4/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol GetToolDataUseCase {
    func getToolData() -> ToolDataModel
}

struct ToolDataModel {
    let title: String
    let category: String
    let languageDirection: LanguageDirection
}

// MARK: - Default

class DefaultGetToolDataUseCase: GetToolDataUseCase {
    
    private let resource: ResourceModel
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices

    init(resource: ResourceModel, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices) {
        self.resource = resource
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
    }
    
    func getToolData() -> ToolDataModel {
        let resourcesCache: ResourcesCache = dataDownloader.resourcesCache
             
        let toolName: String
        let languageBundle: Bundle
        let languageDirection: LanguageDirection
        
        if let primaryLanguage = languageSettingsService.primaryLanguage.value, let primaryTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageId: primaryLanguage.id) {
            
            toolName = primaryTranslation.translatedName
            languageBundle = localizationServices.bundleLoader.bundleForResource(resourceName: primaryLanguage.code) ?? Bundle.main
            languageDirection = primaryLanguage.languageDirection
        }
        else if let englishTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageCode: "en") {
            
            toolName = englishTranslation.translatedName
            languageBundle = localizationServices.bundleLoader.englishBundle ?? Bundle.main
            languageDirection = .leftToRight
        }
        else {
            
            toolName = resource.name
            languageBundle = localizationServices.bundleLoader.englishBundle ?? Bundle.main
            languageDirection = .leftToRight
        }
        
        return ToolDataModel(
            title: toolName,
            category: localizationServices.stringForBundle(bundle: languageBundle, key: "tool_category_\(resource.attrCategory)"),
            languageDirection: languageDirection
        )
    }
}

// MARK: - Mock

class MockGetToolDataUseCase: GetToolDataUseCase {
    let languageDirection: LanguageDirection
    
    init(languageDirection: LanguageDirection) {
        self.languageDirection = languageDirection
    }
    
    func getToolData() -> ToolDataModel {
        return ToolDataModel(title: "Tool Data Title", category: "Tool Category", languageDirection: languageDirection)
    }
}
