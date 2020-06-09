//
//  MyToolsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class MyToolsViewModel: MyToolsViewModelType {
    
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.analytics = analytics
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(screenName: "Home", siteSection: "", siteSubSection: "")
    }
    
    func toolTapped(resource: DownloadedResource) {
        flowDelegate?.navigate(step: .toolTappedFromFavoritedTools(resource: resource))
    }
    
    func toolInfoTapped(resource: DownloadedResource) {
        flowDelegate?.navigate(step: .toolDetailsTappedFromFavoritedTools(resource: resource))
    }
}
