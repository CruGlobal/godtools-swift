//
//  MockToolSpotlightViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class MockToolSpotlightViewModel: ToolSpotlightViewModel {
    
    let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
    
    init() {
        super.init(
            dataDownloader: appDiContainer.initialDataDownloader,
            deviceAttachmentBanners: appDiContainer.deviceAttachmentBanners,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices
        )
    }
}
