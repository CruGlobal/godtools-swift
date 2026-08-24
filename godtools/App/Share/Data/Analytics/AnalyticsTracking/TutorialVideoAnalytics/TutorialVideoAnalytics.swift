//
//  TutorialVideoAnalytics.swift
//  godtools
//
//  Created by Robert Eldredge on 11/12/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

final class TutorialVideoAnalytics: Sendable {
    
    private let trackActionAnalytics: TrackActionAnalytics
    
    init(trackActionAnalytics: TrackActionAnalytics) {
        
        self.trackActionAnalytics = trackActionAnalytics
    }
    
    func trackVideoPlayed(videoId: String, properties: AnalyticsProperties) async {

        let trackAction = TrackActionModel(
            properties: properties,
            actionName: AnalyticsConstants.ActionNames.tutorialVideo,
            url: nil,
            data: [AnalyticsConstants.Keys.tutorialVideo: 1, AnalyticsConstants.Keys.tutorialVideoId: videoId]
        )
        
        await trackActionAnalytics.trackAction(trackAction: trackAction)
    }
}
