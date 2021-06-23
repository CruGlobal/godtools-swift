//
//  ExitLinkAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ExitLinkAnalytics {
    
    private let firebaseAnalytics: FirebaseAnalyticsType
    
    required init(firebaseAnalytics: FirebaseAnalyticsType) {
        self.firebaseAnalytics = firebaseAnalytics
    }
    
    func trackExitLink(exitLink: ExitLinkModel) {
        
        firebaseAnalytics.trackExitLink(
            screenName: exitLink.screenName,
            siteSection: exitLink.siteSection,
            siteSubSection: exitLink.siteSubSection,
            url: exitLink.url
        )        
    }
}
