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
    private let analytics: AnalyticsContainer
    private let visibleAnalyticsEventsObjects: [MobileContentRendererAnalyticsEvent]
    
    init(pageModel: Page, renderedPageContext: MobileContentRenderedPageContext, analytics: AnalyticsContainer, mobileContentAnalytics: MobileContentRendererAnalytics) {
            
        self.pageModel = pageModel
        self.analytics = analytics
        
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
                
        let trackScreenModel = TrackScreenModel(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: renderedPageContext.language.localeIdentifier,
            secondaryContentLanguage: nil
        )
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreenModel)
    }
}
