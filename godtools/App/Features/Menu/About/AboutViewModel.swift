//
//  AboutViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AboutViewModel: AboutViewModelType {
    
    private let aboutTextProvider: AboutTextProviderType
    private let analytics: AnalyticsContainer
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let aboutTexts: ObservableValue<[AboutTextModel]> = ObservableValue(value: [])
    
    required init(aboutTextProvider: AboutTextProviderType, localizationServices: LocalizationServices, analytics: AnalyticsContainer) {
        
        self.aboutTextProvider = aboutTextProvider
        self.analytics = analytics
        
        navTitle.accept(value: localizationServices.stringForMainBundle(key: "aboutApp.navTitle"))
        
        aboutTexts.accept(value: aboutTextProvider.aboutTexts)
    }
    
    private var analyticsScreenName: String {
        return "About"
    }
    
    private var analyticsSiteSection: String {
        return "menu"
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
    
    func pageViewed() {
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
    }
}
