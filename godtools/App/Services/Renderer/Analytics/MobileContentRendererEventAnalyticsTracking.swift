//
//  MobileContentRendererEventAnalyticsTracking.swift
//  godtools
//
//  Created by Levi Eggert on 10/19/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

class MobileContentRendererEventAnalyticsTracking {
    
    private static let actionContentEvent: String = "content_event"
    private static let paramEventId: String = "event_id"
    
    private let firebaseAnalytics: FirebaseAnalyticsInterface
    
    init(firebaseAnalytics: FirebaseAnalyticsInterface) {
        
        self.firebaseAnalytics = firebaseAnalytics
    }
    
    func trackContentEvent(eventId: EventId, resource: ResourceDataModel, appLanguage: String?, languages: MobileContentRendererLanguages) {
        
        let data: [String: Any] = [
            MobileContentRendererEventAnalyticsTracking.paramEventId: eventId.description()
        ]
        
        let properties = AnalyticsProperties(
            screenName: "",
            siteSection: resource.abbreviation,
            siteSubSection: "",
            appLanguage: appLanguage,
            contentLanguage: languages.primaryLanguage.localeId,
            secondaryContentLanguage: languages.parallelLanguage?.localeId
        )
        
        firebaseAnalytics.trackAction(
            properties: properties,
            actionName: MobileContentRendererEventAnalyticsTracking.actionContentEvent,
            data: data
        )
    }
}
