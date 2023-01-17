//
//  UserActivityBadgeDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 1/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

struct UserActivityBadgeDomainModel {
    
    let variant: Int
    let progressTarget: Int
    let badgeType: Badge.BadgeType
    let isEarned: Bool
    
    init(badge: Badge) {
        
        variant = Int(badge.variant)
        progressTarget = Int(badge.progressTarget)
        badgeType = badge.type
        isEarned = badge.isEarned
    }
}

extension UserActivityBadgeDomainModel: Identifiable {
    
    var id: String {
        return "\(badgeType.name)_\(variant)"
    }
}
