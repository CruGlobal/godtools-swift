//
//  ExitLinkAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ExitLinkAnalytics {
    
    private let adobeAnalytics: AdobeAnalyticsType
    private let firebaseAnalytics: FirebaseAnalyticsType
    
    required init(adobeAnalytics: AdobeAnalyticsType, firebaseAnalytics: FirebaseAnalyticsType) {
        self.adobeAnalytics = adobeAnalytics
        self.firebaseAnalytics = firebaseAnalytics
    }
    
    func trackExitLink(exitLink: ExitLinkModel) {
        
        adobeAnalytics.trackExitLink(exitLink: exitLink)
        
        firebaseAnalytics.trackExitLink(exitLink: exitLink)
    }
}
