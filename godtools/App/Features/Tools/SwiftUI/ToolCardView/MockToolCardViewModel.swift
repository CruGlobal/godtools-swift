//
//  MockToolCardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/3/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

class MockToolCardViewModel: ToolCardViewModel {
    let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
    
    init(title: String, category: String, showParallelLanguage: Bool, showBannerImage: Bool) {
        super.init(
                resource: appDiContainer.initialDataDownloader.resourcesCache.getResource(id: "2")!,
                dataDownloader: appDiContainer.initialDataDownloader,
                deviceAttachmentBanners: appDiContainer.deviceAttachmentBanners,
                favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
                languageSettingsService: appDiContainer.languageSettingsService,
                localizationServices: appDiContainer.localizationServices
            )
        
        self.title = title
        self.category = category
        
        if showParallelLanguage {
            parallelLanguageName = "Arabic (Bahrain) ✓"
        }
        
        if showBannerImage, let deviceImage = appDiContainer.deviceAttachmentBanners.getDeviceBanner(resourceId: "2") {
            bannerImage = Image(uiImage: deviceImage)
        }
    }
}
