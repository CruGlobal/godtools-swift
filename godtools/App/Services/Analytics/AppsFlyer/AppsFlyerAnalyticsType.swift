//
//  AppsFlyerType.swift
//  godtools
//
//  Created by Levi Eggert on 3/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol AppsFlyerAnalyticsType: MobileContentAnalyticsSystem {
    
    func configure(adobeAnalytics: AdobeAnalyticsType)
    func trackAppLaunch()
    func trackAction(trackAction: TrackActionModel)
}
