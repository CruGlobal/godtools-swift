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
    
    required init(flowDelegate: FlowDelegate, contentPage: Page, renderedPageContext: MobileContentRenderedPageContext, deepLinkService: DeepLinkingServiceType, analytics: AnalyticsContainer) {
        
        self.contentPage = contentPage
        self.renderedPageContext = renderedPageContext
        self.analytics = analytics
        
        super.init(flowDelegate: flowDelegate, pageModel: contentPage, renderedPageContext: renderedPageContext, deepLinkService: deepLinkService, hidesBackgroundImage: false)
    }
    
    required init(flowDelegate: FlowDelegate, pageModel: Page, renderedPageContext: MobileContentRenderedPageContext, deepLinkService: DeepLinkingServiceType, hidesBackgroundImage: Bool) {
        fatalError("init(flowDelegate:pageModel:renderedPageContext:deepLinkService:hidesBackgroundImage:) has not been implemented")
    }
    
    private func getPageAnalyticsScreenName() -> String {
        
        let resource: ResourceModel = renderedPageContext.resource
        let pageId: String = renderedPageContext.pageModel.id
        let separator: String = ":"
        
        let screenName: String = resource.abbreviation + separator + pageId
        
        return screenName
    }
    
    func pageDidAppear() {
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: getPageAnalyticsScreenName(), siteSection: renderedPageContext.resource.abbreviation, siteSubSection: ""))
    }
}
