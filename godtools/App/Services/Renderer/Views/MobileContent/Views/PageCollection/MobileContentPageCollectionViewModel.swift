//
//  MobileContentPageCollectionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import UIKit
import GodToolsShared

class MobileContentPageCollectionViewModel: MobileContentPageViewModel {
    
    private let pageCollectionPage: PageCollectionPage
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    
    let pagesViewModel: MobileContentPageCollectionPagesViewModel
    
    init(pageCollectionPage: PageCollectionPage, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase) {
        
        self.pagesViewModel = MobileContentPageCollectionPagesViewModel(pageCollectionPage: pageCollectionPage, renderedPageContext: renderedPageContext)
        self.pageCollectionPage = pageCollectionPage
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        super.init(pageModel: pageCollectionPage, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics, trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase, hidesBackgroundImage: false)
    }
}
