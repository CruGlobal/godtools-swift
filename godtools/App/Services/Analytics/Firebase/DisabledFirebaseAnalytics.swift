//
//  DisabledFirebaseAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 8/25/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class DisabledFirebaseAnalytics: FirebaseAnalyticsInterface {
    
    func configure() {
        
    }
    
    func setLoggedInStateUserProperties(isLoggedIn: Bool, loggedInUserProperties: FirebaseAnalyticsLoggedInUserProperties?) {
        
    }
    
    func trackScreenView(properties: AnalyticsProperties) {

    }

    func trackAction(properties: AnalyticsProperties, actionName: String, data: [String: Any]?) {

    }

    func trackExitLink(properties: AnalyticsProperties, url: String) {

    }
}

extension DisabledFirebaseAnalytics: MobileContentRendererAnalyticsSystem {
    
    func trackMobileContentAction(context: MobileContentRenderedPageContext, screenName: String, siteSection: String, action: String, data: [String: Any]?) {
        
    }
}
