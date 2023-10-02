//
//  AnalyticsContainer+TrackExitLinkAnalyticsInterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension AnalyticsContainer: TrackExitLinkAnalyticsInterface {
    
    func trackExitLink(properties: TrackExitLinkAnalyticsPropertiesDomainModel) {
        
        firebaseAnalytics.trackExitLink(
            screenName: properties.screenName,
            siteSection: properties.siteSection,
            siteSubSection: properties.siteSubSection,
            contentLanguage: properties.contentLanguage,
            secondaryContentLanguage: properties.contentLanguageSecondary,
            url: properties.url.absoluteString
        )
    }
}
