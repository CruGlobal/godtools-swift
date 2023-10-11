//
//  TrackActionAnalyticsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class TrackActionAnalyticsUseCase {
    
    private let trackActionAnalytics: TrackActionAnalyticsInterface
    
    init(trackActionAnalytics: TrackActionAnalyticsInterface) {
        
        self.trackActionAnalytics = trackActionAnalytics
    }
    
    func trackAction(screenName: String, actionName: String, siteSection: String, siteSubSection: String, contentLanguage: String?, contentLanguageSecondary: String?, url: String?, data: [String: Any]?) {
        
        let properties = TrackActionAnalyticsPropertiesDomainModel(
            screenName: screenName,
            actionName: actionName,
            siteSection: siteSection,
            siteSubSection: siteSubSection,
            contentLanguage: contentLanguage,
            contentLanguageSecondary: contentLanguageSecondary,
            url: url,
            data: data
        )
        
        trackActionAnalytics.trackAction(
            properties: properties
        )
    }
}
