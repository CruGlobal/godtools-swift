//
//  ToolCategoriesViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI

class ToolCategoriesViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
        
    // MARK: - Published
    
    @Published var buttonViewModels = [ToolCategoryButtonViewModel]()
    @Published var selectedCategory: String?
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices) {
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        
        super.init()
        
        setupBinding()
    }
    
    deinit {
        dataDownloader.cachedResourcesAvailable.removeObserver(self)
        dataDownloader.resourcesUpdatedFromRemoteDatabase.removeObserver(self)
    }
}

// MARK: - Private

extension ToolCategoriesViewModel {
    
    private func setupBinding() {
        
        dataDownloader.cachedResourcesAvailable.addObserver(self) { [weak self] (cachedResourcesAvailable: Bool) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if cachedResourcesAvailable {
                    self.reloadAvailableCategoriesFromCache()
                }
            }
        }
        
        dataDownloader.resourcesUpdatedFromRemoteDatabase.addObserver(self) { [weak self] (error: InitialDataDownloaderError?) in
            DispatchQueue.main.async { [weak self] in
                if error == nil {
                    self?.reloadAvailableCategoriesFromCache()
                }
            }
        }
    }
    
    private func reloadAvailableCategoriesFromCache() {
        let sortedResources: [ResourceModel] = dataDownloader.resourcesCache.getSortedResources()
        let categoryButtonViewModels: [ToolCategoryButtonViewModel] = sortedResources
            .filter({
                let resourceType: ResourceType = $0.resourceTypeEnum
                return (resourceType == .tract || resourceType == .article || resourceType == .chooseYourOwnAdventure) && !$0.isHidden
            })
            .sorted(by: { resource1, resource2 in
                guard let primaryLanguageId = languageSettingsService.primaryLanguage.value?.id else { return true }
                let resourcesCache = dataDownloader.resourcesCache
                
                let resource1HasTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource1.id, languageId: primaryLanguageId) != nil
                    
                let resource2HasTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource2.id, languageId: primaryLanguageId) != nil
                    
                if resource1HasTranslation && resource2HasTranslation {
                    // TODO: - sort by category name alphabetically
                    return true
                    
                } else if resource1HasTranslation {
                    return true
                    
                } else if resource2HasTranslation {
                    return false
                    
                } else {
                    // TODO: - neither have a translation, sort alphabetically
                    return true
                }
                
                // TODO: - remove duplicates
            })
            .map { resource in
                
                let category = resource.attrCategory
                return ToolCategoryButtonViewModel(category: category, selectedCategory: selectedCategory)
            }
        
        buttonViewModels = categoryButtonViewModels
    }
    
//    private func reloadDataForPrimaryLanguage() {
//        let resourcesCache: ResourcesCache = dataDownloader.resourcesCache
//
//        let languageBundle: Bundle
//
//        if let primaryLanguage = languageSettingsService.primaryLanguage.value, let primaryTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageId: primaryLanguage.id) {
//
//            languageBundle = localizationServices.bundleLoader.bundleForResource(resourceName: primaryLanguage.code) ?? Bundle.main
//        }
//        else if let englishTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageCode: "en") {
//
//            languageBundle = localizationServices.bundleLoader.englishBundle ?? Bundle.main
//        }
//        else {
//
//            languageBundle = localizationServices.bundleLoader.englishBundle ?? Bundle.main
//        }
//
//        category = localizationServices.stringForBundle(bundle: languageBundle, key: "tool_category_\(resource.attrCategory)")
//    }
}
