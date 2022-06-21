//
//  ToolCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/09/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolCellViewModel: NSObject, ToolCellViewModelType {
        
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private let deviceAttachmentBanners: DeviceAttachmentBanners
    
    let resource: ResourceModel
    let dataDownloader: InitialDataDownloader
    let bannerImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let attachmentsDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let articlesDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let translationDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let title: ObservableValue<String> = ObservableValue(value: "")
    let category: ObservableValue<String> = ObservableValue(value: "")
    let parallelLanguageName: ObservableValue = ObservableValue(value: "")
    let isFavorited: ObservableValue = ObservableValue(value: false)
    let aboutTitle: ObservableValue<String> = ObservableValue(value: "")
    let openTitle: ObservableValue<String> = ObservableValue(value: "")
    let toolSemanticContentAttribute: ObservableValue<UISemanticContentAttribute> = ObservableValue(value: .forceLeftToRight)
    
    var downloadAttachmentsReceipt: DownloadAttachmentsReceipt?
    var downloadResourceTranslationsReceipt: DownloadTranslationsReceipt?
    
    required init(resource: ResourceModel, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, favoritedResourcesCache: FavoritedResourcesCache, deviceAttachmentBanners: DeviceAttachmentBanners) {
        
        self.resource = resource
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.deviceAttachmentBanners = deviceAttachmentBanners
        
        super.init()
        
        reloadBannerImage()
        reloadDataForPrimaryLanguage()

        setupBinding()
        
        isFavorited.accept(value: favoritedResourcesCache.isFavorited(resourceId: resource.id))
    }
    
    deinit {
        removeDataDownloaderObservers()
        languageSettingsService.primaryLanguage.removeObserver(self)
        languageSettingsService.parallelLanguage.removeObserver(self)
    }
    
    private func setupBinding() {
           
        addDataDownloaderObservers()
        
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
            
        let image: UIImage?
        
        if let cachedImage = dataDownloader.attachmentsFileCache.getAttachmentBanner(attachmentId: resource.attrBanner) {
            image = cachedImage
        }
        else if let deviceImage = deviceAttachmentBanners.getDeviceBanner(resourceId: resource.id) {
            image = deviceImage
        }
        else {
            image = nil
        }
        
        bannerImage.accept(value: image)
    }
    
    private func reloadParallelLanguageName() {

        let parallelLanguage: LanguageModel? = languageSettingsService.parallelLanguage.value
                
        parallelLanguageName.accept(value: getLanguageName(language: parallelLanguage))
    }
    
    private func getLanguageName(language: LanguageModel?) -> String {
        
        if let language = language {
            
            if resource.supportsLanguage(languageId: language.id) {

                return LanguageViewModel(language: language, localizationServices: localizationServices).translatedLanguageNameWithCheckmark
            }
        }
        return ""
    }
    
    private func reloadDataForPrimaryLanguage() {
         
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
        
        title.accept(value: toolName)
                
        category.accept(value: localizationServices.stringForBundle(bundle: languageBundle, key: "tool_category_\(resource.attrCategory)"))
        aboutTitle.accept(value: localizationServices.stringForBundle(bundle: languageBundle, key: "about"))
        openTitle.accept(value: localizationServices.stringForBundle(bundle: languageBundle, key: "open"))
        toolSemanticContentAttribute.accept(value: semanticContentAttribute)
    }
    
    func didDownloadAttachments() {
        
        reloadBannerImage()
    }
}
