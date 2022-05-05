//
//  ToolCardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI

class ToolCardViewModel: BaseToolCardViewModel {
    
    // MARK: - Properties
    
    private let resource: ResourceModel
    private let dataDownloader: InitialDataDownloader
    private let deviceAttachmentBanners: DeviceAttachmentBanners
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    
    // MARK: - Init
    
    init(resource: ResourceModel, dataDownloader: InitialDataDownloader, deviceAttachmentBanners: DeviceAttachmentBanners, favoritedResourcesCache: FavoritedResourcesCache, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices) {
        
        self.resource = resource
        self.dataDownloader = dataDownloader
        self.deviceAttachmentBanners = deviceAttachmentBanners
        self.favoritedResourcesCache = favoritedResourcesCache
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
                
        super.init()
        
        setup()
    }
    
    deinit {
        favoritedResourcesCache.resourceFavorited.removeObserver(self)
        favoritedResourcesCache.resourceUnfavorited.removeObserver(self)
        languageSettingsService.primaryLanguage.removeObserver(self)
        languageSettingsService.parallelLanguage.removeObserver(self)
    }
 
    
    // MARK: - Public
    
    override func favoritedButtonTapped() {
        favoritedResourcesCache.toggleFavorited(resourceId: resource.id)
    }
 
    
    // MARK: - Private
    
    private func setup() {
        setupPublishedProperties()
        setupBinding()
    }
    
    private func setupPublishedProperties() {
        bannerImage = getBannerImage()
        isFavorited = favoritedResourcesCache.isFavorited(resourceId: resource.id)
        
        reloadDataForPrimaryLanguage()
    }
    
    private func setupBinding() {
        favoritedResourcesCache.resourceFavorited.addObserver(self) { [weak self] (resourceId: String) in
            guard let self = self else { return }

            if resourceId == self.resource.id {
                DispatchQueue.main.async { [weak self] in
                    self?.isFavorited = true
                }
            }
        }
        favoritedResourcesCache.resourceUnfavorited.addObserver(self) { [weak self] (resourceId: String) in
            guard let self = self else { return }

            if resourceId == self.resource.id {
                DispatchQueue.main.async { [weak self] in
                    self?.isFavorited = false
                }
            }
        }
        
        languageSettingsService.primaryLanguage.addObserver(self) { [weak self] (primaryLanguage: LanguageModel?) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadDataForPrimaryLanguage()
            }
        }
        languageSettingsService.parallelLanguage.addObserver(self) { [weak self] (parallelLanguage: LanguageModel?) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadParallelLanguageName()
            }
        }
    }
    
    private func getBannerImage() -> Image? {
        
        // TODO: - Eventually refactor existing code to use SwiftUI's Image rather than UIImage
        if let cachedImage = dataDownloader.attachmentsFileCache.getAttachmentBanner(attachmentId: resource.attrBanner) {
            return Image(uiImage: cachedImage)
        }
        else if let deviceImage = deviceAttachmentBanners.getDeviceBanner(resourceId: resource.id) {
            return Image(uiImage: deviceImage)
        }
        else {
            return nil
        }
    }
    
    private func reloadDataForPrimaryLanguage() {
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
        
        title = toolName
        category = localizationServices.stringForBundle(bundle: languageBundle, key: "tool_category_\(resource.attrCategory)")
        layoutDirection = LayoutDirection.from(languageDirection: languageDirection)
    }
    
    private func reloadParallelLanguageName() {
        let parallelLanguage = languageSettingsService.parallelLanguage.value
        parallelLanguageName = getLanguageName(language: parallelLanguage)
    }
    
    private func getLanguageName(language: LanguageModel?) -> String {
        
        if let language = language {
            
            if resource.supportsLanguage(languageId: language.id) {
                let nameAvailableSuffix: String = " ✓"
                let translatedName: String = LanguageViewModel(language: language, localizationServices: localizationServices).translatedLanguageName
                
                return translatedName + nameAvailableSuffix
            }
        }
        return ""
    }
}
