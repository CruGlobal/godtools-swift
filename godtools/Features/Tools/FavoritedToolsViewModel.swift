//
//  FavoritedToolsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class FavoritedToolsViewModel: FavoritedToolsViewModelType {
    
    private let analytics: AnalyticsContainer
    
    let tools: ObservableValue<[DownloadedResource]> = ObservableValue(value: [])
    
    required init(analytics: AnalyticsContainer) {
        
        self.analytics = analytics
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(screenName: "Home", siteSection: "", siteSubSection: "")
    }
}
