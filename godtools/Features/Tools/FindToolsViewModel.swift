//
//  FindToolsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class FindToolsViewModel: FindToolsViewModelType {
    
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.analytics = analytics
    }
    
    func pageViewed() {
        analytics.pageViewedAnalytics.trackPageView(screenName: "Find Tools", siteSection: "tools", siteSubSection: "")
    }
    
    func toolTapped(resource: DownloadedResource) {
        //flowDelegate?.navigate(step: .toolTappedFromAllTools(resource: resource))
    }
    
    func toolInfoTapped(resource: DownloadedResource) {
        //flowDelegate?.navigate(step: .aboutToolTappedFromFavoritedTools(resource: resource))
    }
}
