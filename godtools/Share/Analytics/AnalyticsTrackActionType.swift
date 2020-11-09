//
//  AnalyticsTrackActionType.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol AnalyticsTrackActionType {
    
    func trackAction(action: String, data: [AnyHashable: Any]?)
}
