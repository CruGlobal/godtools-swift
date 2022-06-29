//
//  ResourceBannerImageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 6/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class ResourceBannerImageRepository {
    
    private let attachmentsFileCache: AttachmentsFileCache
    private let bundleBannerImages: BundleResourceBannerImages
    
    init(attachmentsFileCache: AttachmentsFileCache, bundleBannerImages: BundleResourceBannerImages) {
        
        self.attachmentsFileCache = attachmentsFileCache
        self.bundleBannerImages = bundleBannerImages
    }
    
    func getBannerUIImage(resourceId: String, bannerId: String) -> UIImage? {
        
        if let cachedImage = attachmentsFileCache.getAttachmentBanner(attachmentId: bannerId) {
            
            return cachedImage
        }
        else if let bundleImage = bundleBannerImages.getBannerImage(resourceId: resourceId) {
            
            return bundleImage
        }
        
        return nil
    }
    
    func getBannerImage(resourceId: String, bannerId: String) -> Image? {
        
        guard let uiImage = getBannerUIImage(resourceId: resourceId, bannerId: bannerId) else {
            return nil
        }
        
        return Image(uiImage: uiImage)
    }
}
