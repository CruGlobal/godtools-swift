//
//  ToolCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolCellViewModel: NSObject, ToolCellViewModelType {
    
    private let resourcesService: ResourcesService
    //private let attachmentsDownloader: ResourceAttachmentsDownloaderAndCache
    //private let translationsDownloader: ResourceTranslationsDownloaderAndCache
    private let languageSettingsCache: LanguageSettingsCacheType
    private let resource: ResourceModel
    private let resourceId: String
    private let bannerAttachmentId: String
    
    let bannerImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let attachmentDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let translationDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let title: String
    let resourceDescription: String
    let parallelLanguageName: ObservableValue = ObservableValue(value: "")
    let isFavorited: ObservableValue = ObservableValue(value: false)
    
    required init(resource: ResourceModel, resourcesService: ResourcesService, favoritedResourcesCache: RealmFavoritedResourcesCache, languageSettingsCache: LanguageSettingsCacheType) {
        
        self.resourcesService = resourcesService
        //self.attachmentsDownloader = resourcesService.resourceAttachmentsDownloaderAndCacheContainer.getResourceAttachmentsDownloaderAndCache(resouceId: resource.id)
        //self.translationsDownloader = resourcesService.resourceTranslationsDownloaderAndCacheContainer.getResourceTranslationsDownloaderAndCache(resouceId: resource.id)
        self.languageSettingsCache = languageSettingsCache
        self.resource = resource
        self.resourceId = resource.id
        self.bannerAttachmentId = resource.attrBanner
        self.title = resource.name
        self.resourceDescription = resource.attrCategory
        
        super.init()
        
        reloadBannerImage()
        reloadParallelLanguageName()
        setupBinding()
        
        favoritedResourcesCache.isFavorited(resourceId: resource.id) { [weak self] (isFavorited: Bool) in
            self?.isFavorited.accept(value: isFavorited)
        }
    }
    
    deinit {
        //attachmentsDownloader.progress.removeObserver(self)
        //attachmentsDownloader.completed.removeObserver(self)
        //translationsDownloader.progress.removeObserver(self)
        //translationsDownloader.completed.removeObserver(self)
        languageSettingsCache.parallelLanguageId.removeObserver(self)
    }
    
    private func reloadBannerImage() {
        /*
        switch resourcesService.resourcesFileCache.getImage(attachmentId: bannerAttachmentId) {
        case .success(let image):
            bannerImage.accept(value: image)
        case .failure( _):
            break
        }*/
    }
    
    private func reloadParallelLanguageName() {
                
        languageSettingsCache.getParallelLanguage { [weak self] (language: LanguageModel?) in
                        
            if let userParallelLanguage = language {
                let name: String = "✓ " + LanguageNameViewModel(language: userParallelLanguage).name
                self?.parallelLanguageName.accept(value: name)
            }
            else {
                
                self?.parallelLanguageName.accept(value: "")
            }
        }
    }
    
    private func setupBinding() {
            
        /*
        attachmentsDownloader.progress.addObserver(self) { [weak self] (progress: Double) in
            DispatchQueue.main.async { [weak self] in
                self?.attachmentDownloadProgress.accept(value: progress)
            }
        }
        
        attachmentsDownloader.completed.addObserver(self) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.reloadBannerImage()
            }
        }
        
        translationsDownloader.progress.addObserver(self) { [weak self] (progress: Double) in
            DispatchQueue.main.async { [weak self] in
                self?.translationDownloadProgress.accept(value: progress)
            }
        }
        
        translationsDownloader.completed.addObserver(self) { [weak self] in
            
        }*/
        
        languageSettingsCache.parallelLanguageId.addObserver(self) { [weak self] (parallelLanguageId: String?) in
            self?.reloadParallelLanguageName()
        }
    }
}
