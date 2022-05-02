//
//  MockFavoritingToolBannerViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class MockFavoritingToolBannerViewModel: FavoritingToolBannerViewModel {
    
    let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
    
    init(message: String) {
        super.init(favoritingToolMessageCache: appDiContainer.favoritingToolMessageCache, localizationServices: appDiContainer.localizationServices, delegate: nil)
        
        self.message = message
    }
}
