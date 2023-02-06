//
//  UserAnalytics+MobileContentAnalyticsSystem.swift
//  godtools
//
//  Created by Rachael Skeath on 2/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension UserAnalytics: MobileContentAnalyticsSystem {
    
    func trackMobileContentAction(screenName: String, siteSection: String, action: String, data: [String : Any]?) {
        
        // TODO: - track lesson completion analytics
        print("here")
        
    }
}
