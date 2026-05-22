//
//  SyncInvalidatorTimeInterval.swift
//  godtools
//
//  Created by Levi Eggert on 5/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

public enum SyncInvalidatorTimeInterval: Sendable {
    
    case minutes(minute: TimeInterval)
    case hours(hour: TimeInterval)
    case days(day: TimeInterval)
}
