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
    private let rendererPageModel: MobileContentRendererPageModel
    private let analytics: AnalyticsContainer
    
    required init(flowDelegate: FlowDelegate, contentPage: Page, rendererPageModel: MobileContentRendererPageModel, deepLinkService: DeepLinkingServiceType, analytics: AnalyticsContainer) {
        
        self.contentPage = contentPage
        self.rendererPageModel = rendererPageModel
        self.analytics = analytics
        
        super.init(flowDelegate: flowDelegate, pageModel: contentPage, rendererPageModel: rendererPageModel, deepLinkService: deepLinkService, hidesBackgroundImage: false)
    }
    
    required init(flowDelegate: FlowDelegate, pageModel: Page, rendererPageModel: MobileContentRendererPageModel, deepLinkService: DeepLinkingServiceType, hidesBackgroundImage: Bool) {
        fatalError("init(flowDelegate:pageModel:rendererPageModel:deepLinkService:hidesBackgroundImage:) has not been implemented")
    }
    
    private func getPageAnalyticsScreenName() -> String {
        
        let resource: ResourceModel = rendererPageModel.resource
        let pageId: String = rendererPageModel.pageModel.id
        let separator: String = ":"
        
        let screenName: String = resource.abbreviation + separator + pageId
        
        return screenName
    }
    
    func pageDidAppear() {
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: getPageAnalyticsScreenName(), siteSection: rendererPageModel.resource.abbreviation, siteSubSection: ""))
    }
}
