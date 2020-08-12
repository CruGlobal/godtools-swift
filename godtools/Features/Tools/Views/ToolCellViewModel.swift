//
//  ToolCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/09/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolCellViewModel: NSObject, ToolCellViewModelType {
        
    private let resource: ResourceModel
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private let translateLanguageNameViewModel: TranslateLanguageNameViewModel
    private let deviceAttachmentBanners: DeviceAttachmentBanners
    
    private var downloadAttachmentsReceipt: DownloadAttachmentsReceipt?
    private var downloadResourceTranslationsReceipt: DownloadTranslationsReceipt?
    
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
    
    required init(resource: ResourceModel, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, favoritedResourcesCache: FavoritedResourcesCache, deviceAttachmentBanners: DeviceAttachmentBanners) {
        
        self.resource = resource
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.translateLanguageNameViewModel = TranslateLanguageNameViewModel(localizationServices: localizationServices)
        self.deviceAttachmentBanners = deviceAttachmentBanners
        
        super.init()
        
        reloadBannerImage()
        reloadDataForPrimaryLanguage()

        setupBinding()
        
        isFavorited.accept(value: favoritedResourcesCache.isFavorited(resourceId: resource.id))
    }
    
    deinit {
        dataDownloader.attachmentsDownload.removeObserver(self)
        destroyDownloadAttachmentsReceipt()
        dataDownloader.latestTranslationsDownload.removeObserver(self)
        destroyDownloadResourceTranslationsReceipt()
        languageSettingsService.primaryLanguage.removeObserver(self)
        languageSettingsService.parallelLanguage.removeObserver(self)
    }
    
    private func setupBinding() {
           
        dataDownloader.attachmentsDownload.addObserver(self) { [weak self] (receipt: DownloadAttachmentsReceipt?) in
            DispatchQueue.main.async { [weak self] in
                if let receipt = receipt {
                    self?.observeDownloadAttachmentsReceipt(receipt: receipt)
                }
            }
        }
        
        dataDownloader.latestTranslationsDownload.addObserver(self) { [weak self] (receipts: DownloadResourceTranslationsReceipts?) in
            DispatchQueue.main.async { [weak self] in
                if let receipts = receipts, let resourceId = self?.resource.id, let resourceTranslationsDownloadReceipt = receipts.getReceipt(resourceId: resourceId) {
                    self?.observeDownloadResourceTranslationsReceipt(receipt: resourceTranslationsDownloadReceipt)
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
    
    private func destroyDownloadAttachmentsReceipt() {
        if let receipt = downloadAttachmentsReceipt {
            receipt.progressObserver.removeObserver(self)
            receipt.attachmentDownloadedSignal.removeObserver(self)
            receipt.completedSignal.removeObserver(self)
            downloadAttachmentsReceipt = nil
        }
    }
    
    private func observeDownloadAttachmentsReceipt(receipt: DownloadAttachmentsReceipt) {
        
        destroyDownloadAttachmentsReceipt()
        
        receipt.progressObserver.addObserver(self) { [weak self] (progress: Double) in
            DispatchQueue.main.async { [weak self] in
                self?.attachmentsDownloadProgress.accept(value: progress)
            }
        }
        
        receipt.attachmentDownloadedSignal.addObserver(self) { [weak self] (result: DownloadedAttachmentResult) in
            DispatchQueue.main.async { [weak self] in
                guard let attachmentId = self?.resource.attrBanner else {
                    return
                }
                
                if result.downloadError == nil && result.attachmentFile.relatedAttachmentIds.contains(attachmentId) {
                    self?.reloadBannerImage()
                }
            }
        }
    }
    
    private func destroyDownloadResourceTranslationsReceipt() {
        if let receipt = downloadResourceTranslationsReceipt {
            receipt.progressObserver.removeObserver(self)
            receipt.translationDownloadedSignal.removeObserver(self)
            receipt.completedSignal.removeObserver(self)
            downloadResourceTranslationsReceipt = nil
        }
    }
    
    private func observeDownloadResourceTranslationsReceipt(receipt: DownloadTranslationsReceipt) {
        
        destroyDownloadResourceTranslationsReceipt()
        
        receipt.progressObserver.addObserver(self) { [weak self] (progress: Double) in
            DispatchQueue.main.async { [weak self] in
                self?.translationDownloadProgress.accept(value: progress)
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
    
    private func getLanguageName(language: LanguageModelType?) -> String {
        
        if let language = language {
            
            if resource.supportsLanguage(languageId: language.id) {
                let nameAvailablePrefix: String = "✓ "
                let translatedName: String = language.translatedName(translateLanguageNameViewModel: translateLanguageNameViewModel)
                
                return nameAvailablePrefix + translatedName
            }
        }
        return ""
    }
    
    private func reloadDataForPrimaryLanguage() {
         
        let resourcesCache: ResourcesCache = dataDownloader.resourcesCache
             
        let toolName: String
        let languageBundle: Bundle
        
        if let primaryLanguage = languageSettingsService.primaryLanguage.value, let primaryTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageId: primaryLanguage.id) {
            
            toolName = primaryTranslation.translatedName
            languageBundle = localizationServices.bundleForResource(resourceName: primaryLanguage.code) ?? Bundle.main
        }
        else if let englishTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageCode: "en") {
            
            toolName = englishTranslation.translatedName
            languageBundle = localizationServices.englishBundle ?? Bundle.main
        }
        else {
            
            toolName = resource.name
            languageBundle = localizationServices.englishBundle ?? Bundle.main
        }
        
        title.accept(value: toolName)
                
        category.accept(value: localizationServices.stringForBundle(bundle: languageBundle, key: "tool_category_\(resource.attrCategory)"))
        aboutTitle.accept(value: localizationServices.stringForBundle(bundle: languageBundle, key: "about"))
        openTitle.accept(value: localizationServices.stringForBundle(bundle: languageBundle, key: "open"))
    }
}
