//
//  MockLessonCardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

class MockLessonCardViewModel: BaseLessonCardViewModel {
    convenience override init() {
        self.init(title: "title", showBannerImage: true, attachmentsDownloadProgress: 0.5, translationDownloadProgress: 0.3, deviceAttachmentBanners: DeviceAttachmentBanners())
    }
    
    init(title: String, showBannerImage: Bool, attachmentsDownloadProgress: Double, translationDownloadProgress: Double, deviceAttachmentBanners: DeviceAttachmentBanners) {
        super.init()
        
        self.title = title
        
        if showBannerImage {
            bannerImage = Image.from(uiImage: deviceAttachmentBanners.getDeviceBanner(resourceId: "2"))
        }
        
        attachmentsDownloadProgressValue = attachmentsDownloadProgress
        translationDownloadProgressValue = translationDownloadProgress
    }
}
