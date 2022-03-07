//
//  ShareToolRemoteSessionURLViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ShareToolRemoteSessionURLViewModel: ShareToolRemoteSessionURLViewModelType {
        
    private let analytics: AnalyticsContainer
    
    let shareMessage: String
    
    required init(toolRemoteShareUrl: String, localizationServices: LocalizationServices, analytics: AnalyticsContainer) {
              
        self.analytics = analytics
        
        shareMessage = String.localizedStringWithFormat(
            localizationServices.stringForMainBundle(key: "share_tool_remote_link_message"),
            toolRemoteShareUrl
        )
    }
    
    func pageViewed() {
        
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: "", actionName: AnalyticsConstants.ActionNames.shareScreenEngaged, siteSection: "", siteSubSection: "", url: nil, data: [
            AnalyticsConstants.Keys.shareScreenEngagedCountKey: 1
        ]))
    }
}
