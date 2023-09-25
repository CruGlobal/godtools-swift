//
//  TrackExitLinkAnalyticsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class TrackExitLinkAnalyticsUseCase {
    
    private let trackExitLinkAnalytics: TrackExitLinkAnalyticsInterface
    
    init(trackExitLinkAnalytics: TrackExitLinkAnalyticsInterface) {
        
        self.trackExitLinkAnalytics = trackExitLinkAnalytics
    }
    
    func trackExitLinkAnalytics(screenName: String, siteSection: String, siteSubSection: String, contentLanguage: String?, contentLanguageSecondary: String?, url: URL) {
        
        let properties = TrackExitLinkAnalyticsPropertiesDomainModel(
            screenName: screenName,
            siteSection: siteSection,
            siteSubSection: siteSubSection,
            contentLanguage: contentLanguage,
            contentLanguageSecondary: contentLanguageSecondary,
            url: url
        )
        
        trackExitLinkAnalytics.trackExitLink(
            properties: properties
        )
    }
}
