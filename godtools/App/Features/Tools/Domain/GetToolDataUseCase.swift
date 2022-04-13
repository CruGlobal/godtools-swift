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
//    func toolIsFavorited
}

struct ToolDataModel {
    let title: String
    let category: String
    let isFavorited: Bool
    let semanticContentAttribute: UISemanticContentAttribute
}

// MARK: - Default

class DefaultGetToolDataUseCase: GetToolDataUseCase {
    
    private let resource: ResourceModel
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private let favoritedResourcesCache: FavoritedResourcesCache

    init(resource: ResourceModel, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, favoritedResourcesCache: FavoritedResourcesCache) {
        self.resource = resource
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.favoritedResourcesCache = favoritedResourcesCache
    }
    
    func getToolData() -> ToolDataModel {
        let resourcesCache: ResourcesCache = dataDownloader.resourcesCache
             
        let toolName: String
        let languageBundle: Bundle
        let semanticContentAttribute: UISemanticContentAttribute
        
        if let primaryLanguage = languageSettingsService.primaryLanguage.value, let primaryTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageId: primaryLanguage.id) {
            
            toolName = primaryTranslation.translatedName
            languageBundle = localizationServices.bundleLoader.bundleForResource(resourceName: primaryLanguage.code) ?? Bundle.main
            
            switch primaryLanguage.languageDirection {
            case .leftToRight:
                semanticContentAttribute = .forceLeftToRight
            case .rightToLeft:
                semanticContentAttribute = .forceRightToLeft
            }
        }
        else if let englishTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageCode: "en") {
            
            toolName = englishTranslation.translatedName
            languageBundle = localizationServices.bundleLoader.englishBundle ?? Bundle.main
            semanticContentAttribute = .forceLeftToRight
        }
        else {
            
            toolName = resource.name
            languageBundle = localizationServices.bundleLoader.englishBundle ?? Bundle.main
            semanticContentAttribute = .forceLeftToRight
        }
        
        return ToolDataModel(
            title: toolName,
            category: localizationServices.stringForBundle(bundle: languageBundle, key: "tool_category_\(resource.attrCategory)"),
            isFavorited: favoritedResourcesCache.isFavorited(resourceId: resource.id),
            semanticContentAttribute: semanticContentAttribute
        )
    }

    // MARK: - Private
    
    private func setupBinding() {
//        favoritedResourcesCache.resourceFavorited.addObserver(self) { [weak self] (resourceId: String) in
//            DispatchQueue.main.async { [weak self] in
//                self?.reloadTool(resourceId: resourceId)
//            }
//        }
//        
//        favoritedResourcesCache.resourceUnfavorited.addObserver(self) { [weak self] (resourceId: String) in
//            DispatchQueue.main.async { [weak self] in
//                self?.reloadTool(resourceId: resourceId)
//            }
//        }
    }
}

// MARK: - Mock

class MockGetToolDataUseCase: GetToolDataUseCase {
    func getToolData() -> ToolDataModel {
        return ToolDataModel(title: "Tool Data Title", category: "Tool Category", isFavorited: Bool.random(), semanticContentAttribute: .forceLeftToRight)
    }
}
