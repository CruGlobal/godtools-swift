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
    private let resource: RealmResource
    private let resourceId: String
    private let bannerAttachmentId: String
    
    let bannerImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let attachmentDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let translationDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let title: String
    let resourceDescription: String
    let parallelLanguageName: ObservableValue = ObservableValue(value: "")
    let isFavorited: Bool
    
    required init(resource: RealmResource, resourcesService: ResourcesService, favoritedResourcesCache: RealmFavoritedResourcesCache, languageSettingsCache: LanguageSettingsCacheType) {
        
        self.resourcesService = resourcesService
        //self.attachmentsDownloader = resourcesService.resourceAttachmentsDownloaderAndCacheContainer.getResourceAttachmentsDownloaderAndCache(resouceId: resource.id)
        //self.translationsDownloader = resourcesService.resourceTranslationsDownloaderAndCacheContainer.getResourceTranslationsDownloaderAndCache(resouceId: resource.id)
        self.languageSettingsCache = languageSettingsCache
        self.resource = resource
        self.resourceId = resource.id
        self.bannerAttachmentId = resource.attrBanner
        self.title = resource.name
        self.resourceDescription = resource.attrCategory
        self.isFavorited = favoritedResourcesCache.isFavorited(resourceId: resource.id)
        
        super.init()
        
        reloadBannerImage()
        reloadParallelLanguageName()
        setupBinding()
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
        
        let name: String
        
        if let parallelLanguageId = languageSettingsCache.parallelLanguageId.value {
            if let language = resource.languages.filter("id = '\(parallelLanguageId)'").first {
                name = "✓ " + LanguageNameViewModel(language: language).name
            }
            else if let language = resourcesService.resourcesCache.realmCache.getLanguage(id: parallelLanguageId) {
                name = ""//x \(LanguageNameViewModel(language: language).name)" // TODO: Would like to do something here for tools that don't support the parallel language. ~Levi
            }
            else {
                name = ""
            }
        }
        else {
            name = ""
        }
        
        parallelLanguageName.accept(value: name)
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
