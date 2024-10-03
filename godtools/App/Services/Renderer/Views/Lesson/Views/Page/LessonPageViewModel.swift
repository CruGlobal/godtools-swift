//
//  LessonPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class LessonPageViewModel: MobileContentPageViewModel {
    
    private let pageModel: Page
    private let visibleAnalyticsEventsObjects: [MobileContentRendererAnalyticsEvent]
    
    init(pageModel: Page, renderedPageContext: MobileContentRenderedPageContext, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, mobileContentAnalytics: MobileContentRendererAnalytics) {
            
        self.pageModel = pageModel
        
        self.visibleAnalyticsEventsObjects = MobileContentRendererAnalyticsEvent.initAnalyticsEvents(
            analyticsEvents: pageModel.getAnalyticsEvents(type: .visible),
            mobileContentAnalytics: mobileContentAnalytics,
            renderedPageContext: renderedPageContext
        )
        
        super.init(pageModel: pageModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics, trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase, hidesBackgroundImage: false)
    }
    
    override func pageDidAppear() {
        
        super.viewDidAppear(visibleAnalyticsEvents: visibleAnalyticsEventsObjects)
    
        super.pageDidAppear()
    }
}
