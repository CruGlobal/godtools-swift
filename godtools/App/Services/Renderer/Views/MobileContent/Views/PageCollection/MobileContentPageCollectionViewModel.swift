//
//  MobileContentPageCollectionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import UIKit
import GodToolsToolParser

class MobileContentPageCollectionViewModel: MobileContentPageViewModel {
    
    private let pageCollectionPage: PageCollectionPage
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    
    init(pageCollectionPage: PageCollectionPage, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase) {
        
        self.pageCollectionPage = pageCollectionPage
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        super.init(pageModel: pageCollectionPage, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics, trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase, hidesBackgroundImage: false)
    }
    
    var layoutDirection: ApplicationLayoutDirection {
        return renderedPageContext.primaryLanguageLayoutDirection
    }
    
    var numberOfPages: Int {
        return pageCollectionPage.pages.count
    }
}

// MARK: - Inputs

extension MobileContentPageCollectionViewModel {
    
    func pageWillAppear(page: Int) -> MobileContentView? {
        
        let view: MobileContentView? = renderedPageContext.viewRenderer.recurseAndRender(
            renderableModel: pageCollectionPage.pages[page],
            renderableModelParent: nil,
            renderedPageContext: renderedPageContext
        )
                
        return view
    }
    
    func pageDidAppear(page: Int) {
        
    }
}
