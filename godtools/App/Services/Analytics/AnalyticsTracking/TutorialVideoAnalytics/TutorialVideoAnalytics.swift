//
//  TutorialVideoAnalytics.swift
//  godtools
//
//  Created by Robert Eldredge on 11/12/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class TutorialVideoAnalytics {
    
    private let trackActionAnalytics: TrackActionAnalytics
    
    init(trackActionAnalytics: TrackActionAnalytics) {
        
        self.trackActionAnalytics = trackActionAnalytics
    }
    
    func trackVideoPlayed(videoId: String, screenName: String, contentLanguage: String?, secondaryContentLanguage: String?) {
            
        let trackAction = TrackActionModel(
            screenName: screenName,
            actionName: AnalyticsConstants.ActionNames.tutorialVideo,
            siteSection: "",
            siteSubSection: "",
            contentLanguage: contentLanguage,
            secondaryContentLanguage: secondaryContentLanguage,
            url: nil,
            data: [AnalyticsConstants.Keys.tutorialVideo: 1, AnalyticsConstants.Keys.tutorialVideoId: videoId]
        )
        
        trackActionAnalytics.trackAction(trackAction: trackAction)
    }
}
