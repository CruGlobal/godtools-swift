//
//  MobileContentContentPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentContentPageViewModel: MobileContentPageViewModel, MobileContentContentPageViewModelType {
    
    private let contentPage: Page
    private let renderedPageContext: MobileContentRenderedPageContext
    private let analytics: AnalyticsContainer
    
    required init(contentPage: Page, renderedPageContext: MobileContentRenderedPageContext, analytics: AnalyticsContainer) {
        
        self.contentPage = contentPage
        self.renderedPageContext = renderedPageContext
        self.analytics = analytics
        
        super.init(pageModel: contentPage, renderedPageContext: renderedPageContext, hidesBackgroundImage: false)
    }
    
    required init(pageModel: Page, renderedPageContext: MobileContentRenderedPageContext, hidesBackgroundImage: Bool) {
        fatalError("init(pageModel:renderedPageContext:hidesBackgroundImage:) has not been implemented")
    }
    
    private func getPageAnalyticsScreenName() -> String {
        
        let resource: ResourceModel = renderedPageContext.resource
        let pageId: String = renderedPageContext.pageModel.id
        let separator: String = ":"
        
        let screenName: String = resource.abbreviation + separator + pageId
        
        return screenName
    }
    
    func pageDidAppear() {
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: getPageAnalyticsScreenName(), siteSection:analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
    }
}
