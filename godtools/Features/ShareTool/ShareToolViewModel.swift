//
//  ShareToolViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ShareToolViewModel: ShareToolViewModelType {
        
    let shareMessage: String
    
    required init(resource: ResourceModel, language: LanguageModel, pageNumber: Int, localizationServices: LocalizationServices, analytics: AnalyticsContainer) {
                
        var shareUrlString: String = "https://www.knowgod.com/\(language.code)/\(resource.abbreviation)"

        if pageNumber > 0 {
            shareUrlString = shareUrlString.appending("/").appending("\(pageNumber)")
        }
        
        shareUrlString = shareUrlString.replacingOccurrences(of: " ", with: "").appending("?icid=gtshare ")
        
        shareMessage = String.localizedStringWithFormat(
            localizationServices.stringForMainBundle(key: "tract_share_message"),
            shareUrlString
        )
        
        let analyticsScreenName: String = resource.abbreviation + "-" + String(pageNumber)
        
        analytics.pageViewedAnalytics.trackPageView(
            screenName: analyticsScreenName,
            siteSection: resource.abbreviation,
            siteSubSection: ""
        )
                
        analytics.trackActionAnalytics.trackAction(
            screenName: analyticsScreenName,
            actionName: AdobeAnalyticsConstants.Values.share,
            data: [
                AdobeAnalyticsConstants.Keys.shareAction: 1,
                GTConstants.kAnalyticsScreenNameKey: analyticsScreenName
            ]
        )
    }
}
