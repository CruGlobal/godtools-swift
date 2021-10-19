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
    
    func trackContentEvents(eventIds: [MultiplatformEventId], resource: ResourceModel, language: LanguageModel) {
        
        for eventId in eventIds {
            trackContentEvent(eventId: eventId, resource: resource, language: language)
        }
    }
    
    func trackContentEvent(eventId: MultiplatformEventId, resource: ResourceModel, language: LanguageModel) {
        
        let data: [String: Any] = [
            MobileContentEventAnalyticsTracking.paramEventId: eventId.name,
            AnalyticsConstants.Keys.contentLanguage: language.code
        ]
        
        firebaseAnalytics.trackAction(
            screenName: "",
            siteSection: resource.abbreviation,
            siteSubSection: "",
            actionName: MobileContentEventAnalyticsTracking.actionContentEvent,
            data: data
        )
    }
}
