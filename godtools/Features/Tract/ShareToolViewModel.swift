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
    
    required init(resource: DownloadedResource, language: Language, pageNumber: Int, analytics: AnalyticsContainer) {
                
        var shareUrlString: String = "https://www.knowgod.com/\(language.code)/\(resource.code)"

        if pageNumber > 0 {
            shareUrlString = shareUrlString.appending("/").appending("\(pageNumber)")
        }
        
        shareUrlString = shareUrlString.replacingOccurrences(of: " ", with: "").appending("?icid=gtshare ")
        
        shareMessage = String.localizedStringWithFormat(
            "tract_share_message".localized,
            shareUrlString
        )
        
        let analyticsScreenName: String = resource.code + "-" + String(pageNumber)
        
        analytics.pageViewedAnalytics.trackPageView(
            screenName: analyticsScreenName,
            siteSection: resource.code,
            siteSubSection: ""
        )
                
        analytics.adobeAnalytics.trackAction(
            screenName: analyticsScreenName,
            actionName: AdobeAnalyticsConstants.Values.share,
            data: [
                AdobeAnalyticsConstants.Keys.shareAction: 1,
                GTConstants.kAnalyticsScreenNameKey: analyticsScreenName
            ]
        )
    }
}
