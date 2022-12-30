//
//  MobileContentEventAnalyticsTracking.swift
//  godtools
//
//  Created by Levi Eggert on 10/19/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentEventAnalyticsTracking {
    
    private static let actionContentEvent: String = "content_event"
    private static let paramEventId: String = "event_id"
    
    private let firebaseAnalytics: FirebaseAnalytics
    
    required init(firebaseAnalytics: FirebaseAnalytics) {
        
        self.firebaseAnalytics = firebaseAnalytics
    }
    
    func trackContentEvent(eventId: EventId, resource: ResourceModel, language: LanguageDomainModel) {
        
        let data: [String: Any] = [
            MobileContentEventAnalyticsTracking.paramEventId: eventId.description()
        ]
        
        firebaseAnalytics.trackAction(
            screenName: "",
            siteSection: resource.abbreviation,
            siteSubSection: "",
            contentLanguage: language.localeIdentifier,
            secondaryContentLanguage: nil,
            actionName: MobileContentEventAnalyticsTracking.actionContentEvent,
            data: data
        )
    }
}
