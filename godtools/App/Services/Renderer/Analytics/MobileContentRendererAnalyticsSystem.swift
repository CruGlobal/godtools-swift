//
//  MobileContentRendererAnalyticsSystem.swift
//  godtools
//
//  Created by Levi Eggert on 11/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol MobileContentRendererAnalyticsSystem {
    
    func trackMobileContentAction(screenName: String, siteSection: String, action: String, data: [String: Any]?)
}
