//
//  TrackScreenViewAnalyticsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class TrackScreenViewAnalyticsUseCase {
    
    private let trackScreenViewAnalytics: TrackScreenViewAnalyticsInterface
    
    private var lastTrackedScreenName: String = ""
    
    init(trackScreenViewAnalytics: TrackScreenViewAnalyticsInterface) {
        
        self.trackScreenViewAnalytics = trackScreenViewAnalytics
    }
    
    func trackScreen(screenName: String, siteSection: String, siteSubSection: String, appLanguage: String?, contentLanguage: String?, contentLanguageSecondary: String?) {
        
        let properties = TrackScreenViewAnalyticsPropertiesDomainModel(
            previousScreenName: lastTrackedScreenName,
            screenName: screenName,
            siteSection: siteSection,
            siteSubSection: siteSubSection,
            appLanguage: appLanguage,
            contentLanguage: contentLanguage,
            contentLanguageSecondary: contentLanguageSecondary,
            data: nil
        )
        
        trackScreenViewAnalytics.trackScreenView(properties: properties)
        
        lastTrackedScreenName = screenName
    }
}
