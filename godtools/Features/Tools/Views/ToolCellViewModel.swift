//
//  ToolCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolCellViewModel: NSObject, ToolCellViewModelType {
    
    private let resourcesDownloaderAndCache: ResourcesDownloaderAndCache
    private let attachmentsDownloader: ResourceAttachmentsDownloaderAndCache
    private let languageSettingsCache: LanguageSettingsCacheType
    private let resourceId: String
    private let bannerAttachmentId: String
    
    let bannerImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let attachmentDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let title: String
    let resourceDescription: String
    let parallelLanguageName: String
    let isFavorited: Bool
    
    required init(resource: RealmResource, resourcesDownloaderAndCache: ResourcesDownloaderAndCache, favoritedResourcesCache: RealmFavoritedResourcesCache, languageSettingsCache: LanguageSettingsCacheType) {
        
        self.resourcesDownloaderAndCache = resourcesDownloaderAndCache
        self.attachmentsDownloader = resourcesDownloaderAndCache.resourceAttachmentsDownloaderAndCacheContainer.getResourceAttachmentsDownloaderAndCache(resouceId: resource.id)
        self.languageSettingsCache = languageSettingsCache
        self.resourceId = resource.id
        self.bannerAttachmentId = resource.attrBanner
        self.title = resource.name
        self.resourceDescription = resource.attrCategory
        self.isFavorited = favoritedResourcesCache.isFavorited(resourceId: resource.id)
        self.parallelLanguageName = ""
        
        super.init()
        
        // TODO: For each resource - latestTranslation, attach language. ~Levi
        
        reloadBannerImage()
        
        setupBinding()
    }
    
    deinit {
        attachmentsDownloader.progress.removeObserver(self)
        attachmentsDownloader.completed.removeObserver(self)
    }
    
    private func reloadBannerImage() {
        switch resourcesDownloaderAndCache.resourcesFileCache.getImage(attachmentId: bannerAttachmentId) {
        case .success(let image):
            bannerImage.accept(value: image)
        case .failure( _):
            break
        }
    }
    
    private func setupBinding() {
            
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
    }
}
