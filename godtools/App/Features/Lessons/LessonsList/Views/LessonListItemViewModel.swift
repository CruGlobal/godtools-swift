//
//  LessonListItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LessonListItemViewModel: NSObject, LessonListItemViewModelType {
    
    let resource: ResourceModel
    let dataDownloader: InitialDataDownloader
    let title: String
    let bannerImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let attachmentsDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let translationDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    
    var downloadAttachmentsReceipt: DownloadAttachmentsReceipt?
    var downloadResourceTranslationsReceipt: DownloadTranslationsReceipt?
    
    required init(resource: ResourceModel, dataDownloader: InitialDataDownloader) {
        
        self.resource = resource
        self.dataDownloader = dataDownloader
        self.title = resource.resourceDescription
        
        super.init()
        
        reloadBannerImage()
        
        addDataDownloaderObservers()
    }
    
    deinit {
        removeDataDownloaderObservers()
    }
    
    private func reloadBannerImage() {
            
        let image: UIImage?
        
        if let cachedImage = dataDownloader.attachmentsFileCache.getAttachmentBanner(attachmentId: resource.attrBanner) {
            image = cachedImage
        }
        else {
            image = nil
        }
        
        bannerImage.accept(value: image)
    }
    
    func didDownloadAttachments() {
        reloadBannerImage()
    }
}
