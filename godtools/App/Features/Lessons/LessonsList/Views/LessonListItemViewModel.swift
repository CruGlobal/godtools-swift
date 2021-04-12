//
//  LessonListItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LessonListItemViewModel: LessonListItemViewModelType {
    
    private let resource: ResourceModel
    private let dataDownloader: InitialDataDownloader
    
    let title: String
    let bannerImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    
    required init(resource: ResourceModel, dataDownloader: InitialDataDownloader) {
        
        self.resource = resource
        self.dataDownloader = dataDownloader
        self.title = resource.resourceDescription
        
        reloadBannerImage()
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
}
