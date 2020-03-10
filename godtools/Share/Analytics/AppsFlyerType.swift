//
//  AppsFlyerType.swift
//  godtools
//
//  Created by Levi Eggert on 3/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol AppsFlyerType {
    
    func configure()
    func trackAppLaunch()
    func trackEvent(eventName: String, data: [AnyHashable: Any]?)
}
