//
//  ToolCardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI

protocol ToolCardViewModelDelegate: AnyObject {
    func toolCardTapped(resource: ResourceModel)
    func toolFavoriteButtonTapped(resource: ResourceModel)
    func toolDetailsButtonTapped(resource: ResourceModel)
    func openToolButtonTapped(resource: ResourceModel)
}

class ToolCardViewModel: BaseToolCardViewModel, ToolItemInitialDownloadProgress {
    
    // MARK: - Properties
    
    let resource: ResourceModel
    let dataDownloader: InitialDataDownloader
    private let deviceAttachmentBanners: DeviceAttachmentBanners
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private weak var delegate: ToolCardViewModelDelegate?
    
    var attachmentsDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    var translationDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    var downloadAttachmentsReceipt: DownloadAttachmentsReceipt?
    var downloadResourceTranslationsReceipt: DownloadTranslationsReceipt?
    
    // MARK: - Init
    
    init(resource: ResourceModel, dataDownloader: InitialDataDownloader, deviceAttachmentBanners: DeviceAttachmentBanners, favoritedResourcesCache: FavoritedResourcesCache, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, delegate: ToolCardViewModelDelegate?) {
        
        self.resource = resource
        self.dataDownloader = dataDownloader
        self.deviceAttachmentBanners = deviceAttachmentBanners
        self.favoritedResourcesCache = favoritedResourcesCache
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.delegate = delegate
        
        super.init()
        
        setup()
    }
    
    deinit {
        
        removeDataDownloaderObservers()
        
        attachmentsDownloadProgress.removeObserver(self)
        translationDownloadProgress.removeObserver(self)
        favoritedResourcesCache.resourceFavorited.removeObserver(self)
        favoritedResourcesCache.resourceUnfavorited.removeObserver(self)
        languageSettingsService.primaryLanguage.removeObserver(self)
        languageSettingsService.parallelLanguage.removeObserver(self)
    }
    
    // MARK: - Overrides
 
    override func favoriteToolButtonTapped() {
        delegate?.toolFavoriteButtonTapped(resource: resource)
    }
    
    override func toolCardTapped() {
        delegate?.toolCardTapped(resource: resource)
    }

    override func toolDetailsButtonTapped() {
        delegate?.toolDetailsButtonTapped(resource: resource)
    }
    
    override func openToolButtonTapped() {
        delegate?.openToolButtonTapped(resource: resource)
    }
}

// MARK: - Public
 
extension ToolCardViewModel {
 
    func didDownloadAttachments() {
        reloadBannerImage()
    }
    
}

// MARK: - Private

extension ToolCardViewModel {
    
    private func setup() {
        setupPublishedProperties()
        setupBinding()
    }
    
    private func setupPublishedProperties() {
        isFavorited = favoritedResourcesCache.isFavorited(resourceId: resource.id)
        
        reloadDataForPrimaryLanguage()
        reloadBannerImage()
    }
    
    private func setupBinding() {
        
        addDataDownloaderObservers()
        
        attachmentsDownloadProgress.addObserver(self) { [weak self] (progress: Double) in
            DispatchQueue.main.async {
                withAnimation {
                    self?.attachmentsDownloadProgressValue = progress
                }
            }
        }
        translationDownloadProgress.addObserver(self) { [weak self] (progress: Double) in
            DispatchQueue.main.async {
                withAnimation {
                    self?.translationDownloadProgressValue = progress
                }
            }
        }
        
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
    
    private func reloadBannerImage() {
        let image: Image?
        
        // TODO: - Eventually refactor existing code to use SwiftUI's Image rather than UIImage
        if let cachedImage = dataDownloader.attachmentsFileCache.getAttachmentBanner(attachmentId: resource.attrBanner) {
            image = Image(uiImage: cachedImage)
        }
        else if let deviceImage = deviceAttachmentBanners.getDeviceBanner(resourceId: resource.id) {
            image = Image(uiImage: deviceImage)
        }
        else {
            image = nil
        }
        
        bannerImage = image
    }
    
    private func reloadDataForPrimaryLanguage() {
        let resourcesCache: ResourcesCache = dataDownloader.resourcesCache
        let bundleLoader = localizationServices.bundleLoader
        
        let toolName: String
        let languageBundle: Bundle
        let languageDirection: LanguageDirection
        
        if let primaryLanguage = languageSettingsService.primaryLanguage.value, let primaryTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageId: primaryLanguage.id) {
            
            toolName = primaryTranslation.translatedName
            languageBundle = bundleLoader.bundleForResource(resourceName: primaryLanguage.code) ?? Bundle.main
            languageDirection = primaryLanguage.languageDirection
        }
        else if let englishTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageCode: "en") {
            
            toolName = englishTranslation.translatedName
            languageBundle = bundleLoader.englishBundle ?? Bundle.main
            languageDirection = .leftToRight
        }
        else {
            
            toolName = resource.name
            languageBundle = bundleLoader.englishBundle ?? Bundle.main
            languageDirection = .leftToRight
        }
        
        title = toolName
        category = localizationServices.toolCategoryStringForBundle(bundle: languageBundle, attrCategory: resource.attrCategory)
        detailsButtonTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "favorites.favoriteLessons.details")
        openButtonTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "open")
        layoutDirection = LayoutDirection.from(languageDirection: languageDirection)
    }
    
    private func reloadParallelLanguageName() {
        let parallelLanguage = languageSettingsService.parallelLanguage.value
        parallelLanguageName = getLanguageName(language: parallelLanguage)
    }
    
    private func getLanguageName(language: LanguageModel?) -> String {
        
        if let language = language {
            
            if resource.supportsLanguage(languageId: language.id) {
               
                return LanguageViewModel(language: language, localizationServices: localizationServices).translatedLanguageNameWithCheckmark
            }
        }
        return ""
    }
}
