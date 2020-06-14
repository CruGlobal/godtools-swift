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
    private let resourceId: String
    private let bannerAttachmentId: String
    
    let bannerImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let title: String
    let resourceDescription: String
    let isFavorited: Bool
    
    required init(resource: RealmResource, resourcesDownloaderAndCache: ResourcesDownloaderAndCache, favoritedResourcesCache: RealmFavoritedResourcesCache) {
        
        self.resourcesDownloaderAndCache = resourcesDownloaderAndCache
        self.attachmentsDownloader = resourcesDownloaderAndCache.resourceAttachmentsDownloaderAndCacheContainer.getResourceAttachmentsDownloaderAndCache(resouceId: resource.id)
        self.resourceId = resource.id
        self.bannerAttachmentId = resource.attrBanner
        self.title = resource.name
        self.resourceDescription = resource.attrCategory
        self.isFavorited = favoritedResourcesCache.isFavorited(resourceId: resource.id)
        
        super.init()
        
        reloadBannerImage()
        
        setupBinding()
    }
    
    deinit {
        
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
                
            }
        }
        
        attachmentsDownloader.completed.addObserver(self) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.reloadBannerImage()
            }
        }
    }
}
