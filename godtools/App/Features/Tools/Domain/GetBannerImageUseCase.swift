//
//  GetBannerImageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 4/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI

protocol GetBannerImageUseCase {
    func getBannerImage() -> Image?
}

// MARK: - Default

class DefaultGetBannerImageUseCase: GetBannerImageUseCase {
    
    private let resource: ResourceModel
    private let dataDownloader: InitialDataDownloader
    private let deviceAttachmentBanners: DeviceAttachmentBanners
    
    init(resource: ResourceModel, dataDownloader: InitialDataDownloader, deviceAttachmentBanners: DeviceAttachmentBanners) {
        self.resource = resource
        self.dataDownloader = dataDownloader
        self.deviceAttachmentBanners = deviceAttachmentBanners
    }
    
    func getBannerImage() -> Image? {
        
        // TODO: - Eventually refactor existing code to use SwiftUI's Image rather than UIImage
        if let cachedImage = dataDownloader.attachmentsFileCache.getAttachmentBanner(attachmentId: resource.attrBanner) {
            return Image(uiImage: cachedImage)
        }
        else if let deviceImage = deviceAttachmentBanners.getDeviceBanner(resourceId: resource.id) {
            return Image(uiImage: deviceImage)
        }
        else {
            return nil
        }
    }
}

// MARK: - Mock

class MockGetBannerImageUseCase: GetBannerImageUseCase {
    
    var nilImage: Bool = false
    
    private static let bannerImageNames = ["banner1", "banner2"]
    
    init(nilImage: Bool = false) {
        self.nilImage = nilImage
    }
    
    func getBannerImage() -> Image? {
        return nilImage ? nil : Image(MockGetBannerImageUseCase.bannerImageNames.randomElement()!)
    }
}
