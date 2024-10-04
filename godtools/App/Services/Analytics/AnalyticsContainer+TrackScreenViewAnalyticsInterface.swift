//
//  AnalyticsContainer+TrackScreenViewAnalyticsInterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension AnalyticsContainer: TrackScreenViewAnalyticsInterface {
    
    func trackScreenView(properties: TrackScreenViewAnalyticsPropertiesDomainModel) {
        
        firebaseAnalytics.trackScreenView(
            screenName: properties.screenName,
            siteSection: properties.siteSection,
            siteSubSection: properties.siteSubSection,
            appLanguage: properties.appLanguage,
            contentLanguage: properties.contentLanguage,
            secondaryContentLanguage: properties.contentLanguageSecondary
        )
    }
}
