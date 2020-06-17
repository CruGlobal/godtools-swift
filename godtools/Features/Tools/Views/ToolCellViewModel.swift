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
    //private let translationsDownloader: ResourceTranslationsDownloaderAndCache
    private let languageSettingsCache: LanguageSettingsCacheType
    private let resource: ResourceModel
    
    let bannerImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let translationDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let title: String
    let resourceDescription: String
    let parallelLanguageName: ObservableValue = ObservableValue(value: "")
    let isFavorited: ObservableValue = ObservableValue(value: false)
    
    required init(resource: ResourceModel, resourcesService: ResourcesService, favoritedResourcesCache: RealmFavoritedResourcesCache, languageSettingsCache: LanguageSettingsCacheType) {
        
        self.resourcesService = resourcesService
        //self.translationsDownloader = resourcesService.resourceTranslationsDownloaderAndCacheContainer.getResourceTranslationsDownloaderAndCache(resouceId: resource.id)
        self.languageSettingsCache = languageSettingsCache
        self.resource = resource
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
        resourcesService.attachmentsService.completed.removeObserver(self)
        //translationsDownloader.progress.removeObserver(self)
        //translationsDownloader.completed.removeObserver(self)
        languageSettingsCache.parallelLanguageId.removeObserver(self)
    }
    
    private func reloadBannerImage() {
        resourcesService.attachmentsService.getAttachmentBanner(attachmentId: resource.attrBanner) { [weak self] (image: UIImage?) in
            self?.bannerImage.accept(value: image)
        }
    }
    
    private func reloadParallelLanguageName() {

        let userParallelLanguageId: String? = languageSettingsCache.parallelLanguageId.value
        
        resourcesService.realmResourcesCache.getResourceLanguage(resourceId: resource.id, languageId: userParallelLanguageId ?? "") { [weak self] (language: LanguageModel?) in
            if let resourceSupportsParallelLanguage = language {
                let name: String = "✓ " + LanguageNameViewModel(language: resourceSupportsParallelLanguage).name
                self?.parallelLanguageName.accept(value: name)
            }
            else {
                
                self?.parallelLanguageName.accept(value: "")
            }
        }
    }
    
    private func setupBinding() {
        
        resourcesService.attachmentsService.completed.addObserver(self) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.reloadBannerImage()
            }
        }
        /*
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
