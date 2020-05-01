//
//  FirebaseAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import FirebaseAnalytics

class FirebaseAnalytics: FirebaseAnalyticsType {
    
    required init() {
        
    }
    
    func trackScreenView(screenName: String) {
        Analytics.setScreenName(screenName, screenClass: nil)
    }
}
