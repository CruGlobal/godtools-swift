//
//  AboutViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AboutViewModel: AboutViewModelType {
    
    private let analytics: AnalyticsContainer
    
    let navTitle: ObservableValue<String> = ObservableValue(value: NSLocalizedString("about", comment: ""))
    
    required init(analytics: AnalyticsContainer) {
        
        self.analytics = analytics        
    }
    
    func pageViewed() {
        analytics.pageViewedAnalytics.trackPageView(screenName: "About", siteSection: "menu", siteSubSection: "")
    }
}
