//
//  FirebaseAnalytics+MobileContentAnalyticsSystem.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

extension FirebaseAnalytics: MobileContentAnalyticsSystem {
    
    func trackMobileContentAction(screenName: String, siteSection: String, action: String, data: [String: Any]?) {
        
        trackAction(
            screenName: screenName,
            siteSection: siteSection,
            siteSubSection: "",
            contentLanguage: nil,
            secondaryContentLanguage: nil,
            actionName: action,
            data: data
        )
    }
}
