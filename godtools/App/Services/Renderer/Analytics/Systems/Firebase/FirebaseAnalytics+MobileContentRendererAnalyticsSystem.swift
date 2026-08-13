//
//  FirebaseAnalytics+MobileContentRendererAnalyticsSystem.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

extension FirebaseAnalytics: MobileContentRendererAnalyticsSystem {
    
    func trackMobileContentAction(
        screenName: String,
        siteSection: String,
        appLanguage: AppLanguageDomainModel,
        contentLanguage: BCP47LanguageIdentifier,
        secondaryContentLanguage: BCP47LanguageIdentifier?,
        action: String,
        data: [String: Any]?
    ) {
        
        let properties = AnalyticsProperties(
            screenName: screenName,
            siteSection: siteSection,
            siteSubSection: "",
            appLanguage: appLanguage,
            contentLanguage: contentLanguage,
            secondaryContentLanguage: secondaryContentLanguage
        )
        
        trackAction(properties: properties, actionName: action, data: data)
    }
}
