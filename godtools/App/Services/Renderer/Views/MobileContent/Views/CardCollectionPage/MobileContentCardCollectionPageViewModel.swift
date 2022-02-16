//
//  MobileContentCardCollectionPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentCardCollectionPageViewModel: MobileContentPageViewModel, MobileContentCardCollectionPageViewModelType {
    
    private let cardCollectionPage: MultiplatformCardCollectionPage
    private let rendererPageModel: MobileContentRendererPageModel
    private let analytics: AnalyticsContainer
        
    required init(flowDelegate: FlowDelegate, cardCollectionPage: MultiplatformCardCollectionPage, rendererPageModel: MobileContentRendererPageModel, deepLinkService: DeepLinkingServiceType, analytics: AnalyticsContainer) {
        
        self.cardCollectionPage = cardCollectionPage
        self.rendererPageModel = rendererPageModel
        self.analytics = analytics
        
        super.init(flowDelegate: flowDelegate, pageModel: cardCollectionPage, rendererPageModel: rendererPageModel, deepLinkService: deepLinkService, hidesBackgroundImage: false)
    }
    
    required init(flowDelegate: FlowDelegate, pageModel: PageModelType, rendererPageModel: MobileContentRendererPageModel, deepLinkService: DeepLinkingServiceType, hidesBackgroundImage: Bool) {
        fatalError("init(flowDelegate:pageModel:rendererPageModel:deepLinkService:hidesBackgroundImage:) has not been implemented")
    }
    
    func pageDidAppear(page: Int) {
        
        let resource: ResourceModel = rendererPageModel.resource
        
        // TODO: Use pageId and cardId to track analytics. ~Levi
        //analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: resource.abbreviation + "-" + String(page), siteSection: resource.abbreviation, siteSubSection: ""))
    }
}
