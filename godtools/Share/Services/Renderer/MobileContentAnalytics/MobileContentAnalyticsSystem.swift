//
//  MobileContentAnalyticsSystem.swift
//  godtools
//
//  Created by Levi Eggert on 11/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol MobileContentAnalyticsSystem {
    
    func trackAction(action: String, data: [String: Any]?)
}
