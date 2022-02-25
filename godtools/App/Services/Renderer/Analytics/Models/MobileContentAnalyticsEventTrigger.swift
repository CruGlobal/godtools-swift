//
//  MobileContentAnalyticsEventTrigger.swift
//  godtools
//
//  Created by Levi Eggert on 7/19/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

// TODO: Is this provided by shared multiplatform parser? ~Levi
enum MobileContentAnalyticsEventTrigger {
    
    case dependentOnContainingElement
    case hidden
    case selected
    case visible
}
