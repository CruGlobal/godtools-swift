//
//  MobileContentEventAnalyticsTracking.swift
//  godtools
//
//  Created by Levi Eggert on 10/19/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentEventAnalyticsTracking {
    
    private static let actionContentEvent: String = "content_event"
    private static let paramEventId: String = "event_id"
    
    private let firebaseAnalytics: FirebaseAnalyticsType
    
    required init(firebaseAnalytics: FirebaseAnalyticsType) {
        
        self.firebaseAnalytics = firebaseAnalytics
    }
    
    func trackContentEvents(eventIds: [MultiplatformEventId]) {
        
        for eventId in eventIds {
            trackContentEvent(eventId: eventId)
        }
    }
    
    func trackContentEvent(eventId: MultiplatformEventId) {
        
        let data: [String: Any] = [
            MobileContentEventAnalyticsTracking.paramEventId: eventId.name
        ]
        
        firebaseAnalytics.trackAction(
            screenName: "",
            siteSection: "",
            siteSubSection: "",
            actionName: MobileContentEventAnalyticsTracking.actionContentEvent,
            data: data
        )
    }
}
