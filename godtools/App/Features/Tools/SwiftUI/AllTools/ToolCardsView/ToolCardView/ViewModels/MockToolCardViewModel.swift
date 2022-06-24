//
//  MockToolCardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/3/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

class MockToolCardViewModel: BaseToolCardViewModel {
    
    convenience init() {
        self.init(cardType: .square, title: "title", category: "category", showParallelLanguage: true, showBannerImage: true, attachmentsDownloadProgress: 0.5, translationDownloadProgress: 0.3, deviceAttachmentBanners: DeviceAttachmentBanners())
    }
    
    init(cardType: ToolCardType, title: String, category: String, showParallelLanguage: Bool, showBannerImage: Bool, attachmentsDownloadProgress: Double, translationDownloadProgress: Double, deviceAttachmentBanners: DeviceAttachmentBanners) {
        super.init(cardType: cardType)
        
        self.title = title
        self.category = category
        
        if showParallelLanguage {
            parallelLanguageName = "Arabic (Bahrain) ✓"
        }
        
        if showBannerImage {
            bannerImage = Image.from(uiImage: deviceAttachmentBanners.getDeviceBanner(resourceId: "2"))
        }
        
        attachmentsDownloadProgressValue = attachmentsDownloadProgress
        translationDownloadProgressValue = translationDownloadProgress
    }
}
