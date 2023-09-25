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
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let visibleAnalyticsEventsObjects: [MobileContentRendererAnalyticsEvent]
    
    init(pageModel: Page, renderedPageContext: MobileContentRenderedPageContext, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, mobileContentAnalytics: MobileContentRendererAnalytics) {
            
        self.pageModel = pageModel
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        self.visibleAnalyticsEventsObjects = MobileContentRendererAnalyticsEvent.initAnalyticsEvents(
            analyticsEvents: pageModel.getAnalyticsEvents(type: .visible),
            mobileContentAnalytics: mobileContentAnalytics,
            renderedPageContext: renderedPageContext
        )
        
        super.init(pageModel: pageModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics, hidesBackgroundImage: false)
    }
}

// MARK: - Inputs

extension LessonPageViewModel {
    
    func pageDidAppear() {
        
        super.viewDidAppear(visibleAnalyticsEvents: visibleAnalyticsEventsObjects)
          
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: renderedPageContext.language.localeIdentifier,
            contentLanguageSecondary: nil
        )
    }
}
