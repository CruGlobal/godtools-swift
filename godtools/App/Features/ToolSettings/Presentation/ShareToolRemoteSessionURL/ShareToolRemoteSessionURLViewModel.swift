//
//  ShareToolRemoteSessionURLViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ShareToolRemoteSessionURLViewModel {
        
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    
    let shareMessage: String
    
    init(toolRemoteShareUrl: String, localizationServices: LocalizationServices, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
              
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        
        shareMessage = String.localizedStringWithFormat(
            localizationServices.stringForSystemElseEnglish(key: "share_tool_remote_link_message"),
            toolRemoteShareUrl
        )
    }
}

// MARK: - Inputs

extension ShareToolRemoteSessionURLViewModel {
    
    func pageViewed() {
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: "",
            actionName: AnalyticsConstants.ActionNames.shareScreenEngaged,
            siteSection: "",
            siteSubSection: "",
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [
                AnalyticsConstants.Keys.shareScreenEngagedCountKey: 1
            ]
        )
    }
}
