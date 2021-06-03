//
//  SnowplowAnalyticsType.swift
//  godtools
//
//  Created by Robert Eldredge on 5/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol SnowplowAnalyticsType: MobileContentAnalyticsSystem {

    func configure(adobeAnalytics: AdobeAnalyticsType)
    func trackScreenView(trackScreen: TrackScreenModel)
    func trackAction(trackAction: TrackActionModel)
}

