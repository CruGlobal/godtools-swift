//
//  AppsFlyerType.swift
//  godtools
//
//  Created by Levi Eggert on 3/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol AppsFlyerAnalyticsType: MobileContentAnalyticsSystem {
    
    func configure()
    func trackAppLaunch()
    func trackAction(actionName: String, data: [String : Any]?)
}
