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
    
    required init(trackActionAnalytics: TrackActionAnalytics) {
        
        self.trackActionAnalytics = trackActionAnalytics
    }
    
    func trackVideoPlayed(videoId: String, screenName: String) {
            
        trackActionAnalytics.trackAction(
            trackAction: TrackActionModel(
                screenName: screenName,
                actionName: AnalyticsConstants.ActionNames.tutorialVideo,
                siteSection: "",
                siteSubSection: "",
                url: nil,
                data: [AnalyticsConstants.Keys.tutorialVideo: 1, AnalyticsConstants.Keys.tutorialVideoId: videoId]
            )
        )
    }
}
