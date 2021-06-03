//
//  ShareToolViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ShareToolViewModel: ShareToolViewModelType {
        
    private let resource: ResourceModel
    private let analytics: AnalyticsContainer
    private let pageNumber: Int
    
    let shareMessage: String
    
    required init(resource: ResourceModel, language: LanguageModel, pageNumber: Int, localizationServices: LocalizationServices, analytics: AnalyticsContainer) {
                
        self.resource = resource
        self.analytics = analytics
        self.pageNumber = pageNumber
        
        var shareUrlString: String = "https://www.knowgod.com/\(language.code)/\(resource.abbreviation)"

        if pageNumber > 0 {
            shareUrlString = shareUrlString.appending("/").appending("\(pageNumber)")
        }
        
        shareUrlString = shareUrlString.replacingOccurrences(of: " ", with: "").appending("?icid=gtshare ")
        
        shareMessage = String.localizedStringWithFormat(
            localizationServices.stringForMainBundle(key: "tract_share_message"),
            shareUrlString
        )
    }
    
    func pageViewed() {
        
        let analyticsScreenName: String = resource.abbreviation + "-" + String(pageNumber)
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: resource.abbreviation, siteSubSection: "", url: nil))
                
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: analyticsScreenName, actionName: AnalyticsConstants.Values.shareIconEngaged, siteSection: nil, siteSubSection: nil, url: nil, data: [
            AnalyticsConstants.ActionNames.shareIconEngagedCountKey: 1
        ]))
    }
}
