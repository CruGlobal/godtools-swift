//
//  AnalyticsContainer+TrackActionAnalyticsInterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension AnalyticsContainer: TrackActionAnalyticsInterface {
    
    func trackAction(properties: TrackActionAnalyticsPropertiesDomainModel) {
        
        firebaseAnalytics.trackAction(
            screenName: properties.screenName,
            siteSection: properties.siteSection,
            siteSubSection: properties.siteSubSection,
            contentLanguage: properties.contentLanguage,
            secondaryContentLanguage: properties.contentLanguageSecondary,
            actionName: properties.actionName,
            data: properties.data
        )
    }
}
