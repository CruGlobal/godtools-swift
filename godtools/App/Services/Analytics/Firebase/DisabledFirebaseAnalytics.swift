//
//  DisabledFirebaseAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 8/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class DisabledFirebaseAnalytics: FirebaseAnalyticsInterface {
    
    init() {
        
    }
    
    func configure() {
        
    }
    
    func setLoggedInStateUserProperties(isLoggedIn: Bool, loggedInUserProperties: FirebaseAnalyticsLoggedInUserProperties?) {
        
    }
    
    func trackScreenView(screenName: String, siteSection: String, siteSubSection: String, appLanguage: String?, contentLanguage: String?, secondaryContentLanguage: String?) {
        
    }
    
    func trackAction(screenName: String, siteSection: String, siteSubSection: String, appLanguage: String?, contentLanguage: String?, secondaryContentLanguage: String?, actionName: String, data: [String: Any]?) {
        
    }
    
    func trackExitLink(screenName: String, siteSection: String, siteSubSection: String, appLanguage: String?, contentLanguage: String?, secondaryContentLanguage: String?, url: String) {
        
    }
}
