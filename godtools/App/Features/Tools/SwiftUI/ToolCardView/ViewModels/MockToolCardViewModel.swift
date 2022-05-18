//
//  MockToolCardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/3/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

class MockToolCardViewModel: BaseToolCardViewModel {
    
    init(title: String, category: String, showParallelLanguage: Bool, showBannerImage: Bool, attachmentsDownloadProgress: Double, translationDownloadProgress: Double) {
        super.init()
        
        self.title = title
        self.category = category
        
        if showParallelLanguage {
            parallelLanguageName = "Arabic (Bahrain) ✓"
        }
        
        if showBannerImage {
            bannerImage = Image.from(uiImage: DeviceAttachmentBanners().getDeviceBanner(resourceId: "2"))
        }
        
        attachmentsDownloadProgressValue = attachmentsDownloadProgress
        translationDownloadProgressValue = translationDownloadProgress
    }
}
